"""
orchestration/alerting.py
=========================
Production Notification and Alerting Engine for MycoMetrics.

Generates standard, schema-compliant webhook alert payloads for:
1. Slack Block Kit (interactive blocks, key-value fields, color indicators)
2. Microsoft Teams Adaptive Cards v1.4 (fact sets, status badges, expandable diagnostics)
3. Generic REST Webhooks (standard JSON envelopes for PagerDuty, Discord, Datadog)

Persistence & Reliability:
- Thread-safe, dependency-free HTTP POST dispatch using urllib.request.
- Deterministic offline audit logging: persists all payloads to `data/audit_logs/alerts/`
  ensuring end-to-end traceability during local development, CI/CD runs, and air-gapped deployments.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.request
import urllib.error
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Optional


class PipelineAlertManager:
    """
    Manages formatting, logging, and dispatching of data pipeline alerts.
    """

    def __init__(
        self,
        alert_dir: str | Path = "data/audit_logs/alerts",
        slack_webhook_url: Optional[str] = None,
        teams_webhook_url: Optional[str] = None,
        generic_webhook_url: Optional[str] = None,
    ):
        self.alert_dir = Path(alert_dir)
        self.alert_dir.mkdir(parents=True, exist_ok=True)
        self.slack_webhook_url = slack_webhook_url or os.getenv("SLACK_WEBHOOK_URL")
        self.teams_webhook_url = teams_webhook_url or os.getenv("TEAMS_WEBHOOK_URL")
        self.generic_webhook_url = generic_webhook_url or os.getenv("ALERT_WEBHOOK_URL")

    def build_slack_payload(
        self,
        title: str,
        status: str,
        run_id: str,
        stage: str,
        duration_seconds: float,
        metrics: Optional[Dict[str, Any]] = None,
        error_message: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Construct a Slack Block Kit JSON message payload.
        """
        metrics = metrics or {}
        status_upper = status.upper()
        emoji = "PASS" if status_upper in ("SUCCESS", "PASS") else "ALERT"
        status_color = "#2EB886" if status_upper in ("SUCCESS", "PASS") else "#E01E5A"

        fields = [
            {"type": "mrkdwn", "text": f"*Run ID:*\n`{run_id}`"},
            {"type": "mrkdwn", "text": f"*Stage:*\n`{stage}`"},
            {"type": "mrkdwn", "text": f"*Status:*\n*{status_upper}*"},
            {"type": "mrkdwn", "text": f"*Duration:*\n{duration_seconds:.2f}s"},
        ]

        for k, v in metrics.items():
            fields.append({"type": "mrkdwn", "text": f"*{k.replace('_', ' ').title()}:*\n{v}"})

        blocks = [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": f"[{emoji}] MycoMetrics Pipeline: {title}",
                    "emoji": False,
                },
            },
            {
                "type": "section",
                "fields": fields,
            },
        ]

        if error_message:
            blocks.append({
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Diagnostics / Failure Trace:*\n```{error_message[:2000]}```",
                },
            })

        blocks.append({
            "type": "context",
            "elements": [
                {
                    "type": "mrkdwn",
                    "text": f"Timestamp: {datetime.now(timezone.utc).isoformat()} | Environment: Production / Automated",
                }
            ],
        })

        return {
            "attachments": [
                {
                    "color": status_color,
                    "blocks": blocks,
                }
            ]
        }

    def build_teams_payload(
        self,
        title: str,
        status: str,
        run_id: str,
        stage: str,
        duration_seconds: float,
        metrics: Optional[Dict[str, Any]] = None,
        error_message: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Construct a Microsoft Teams Adaptive Card v1.4 JSON payload.
        """
        metrics = metrics or {}
        status_upper = status.upper()
        is_success = status_upper in ("SUCCESS", "PASS")
        card_color = "Good" if is_success else "Attention"

        facts = [
            {"title": "Run ID", "value": run_id},
            {"title": "Pipeline Stage", "value": stage},
            {"title": "Execution Status", "value": status_upper},
            {"title": "Duration", "value": f"{duration_seconds:.2f} seconds"},
        ]
        for k, v in metrics.items():
            facts.append({"title": k.replace("_", " ").title(), "value": str(v)})

        body: list[dict[str, Any]] = [
            {
                "type": "TextBlock",
                "size": "Medium",
                "weight": "Bolder",
                "text": f"MycoMetrics Warehouse: {title}",
                "color": card_color,
            },
            {
                "type": "FactSet",
                "facts": facts,
            },
        ]

        if error_message:
            body.append({
                "type": "TextBlock",
                "weight": "Bolder",
                "text": "Error Diagnostics:",
                "color": "Attention",
            })
            body.append({
                "type": "TextBlock",
                "text": error_message[:2000],
                "wrap": True,
                "fontType": "Monospace",
                "size": "Small",
            })

        return {
            "type": "message",
            "attachments": [
                {
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "contentUrl": None,
                    "content": {
                        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "type": "AdaptiveCard",
                        "version": "1.4",
                        "body": body,
                    },
                }
            ],
        }

    def build_generic_payload(
        self,
        title: str,
        status: str,
        run_id: str,
        stage: str,
        duration_seconds: float,
        metrics: Optional[Dict[str, Any]] = None,
        error_message: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Construct a generic standardized JSON alert payload.
        """
        return {
            "source": "mycometrics_pipeline",
            "title": title,
            "status": status.upper(),
            "run_id": run_id,
            "stage": stage,
            "duration_seconds": round(duration_seconds, 2),
            "metrics": metrics or {},
            "error_message": error_message,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    def dispatch(
        self,
        title: str,
        status: str,
        run_id: str,
        stage: str,
        duration_seconds: float,
        metrics: Optional[Dict[str, Any]] = None,
        error_message: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Builds, persists locally, and attempts remote webhooks dispatch.
        Returns a summary report of persistence and delivery attempts.
        """
        slack_payload = self.build_slack_payload(title, status, run_id, stage, duration_seconds, metrics, error_message)
        teams_payload = self.build_teams_payload(title, status, run_id, stage, duration_seconds, metrics, error_message)
        generic_payload = self.build_generic_payload(title, status, run_id, stage, duration_seconds, metrics, error_message)

        # 1. Deterministic Local Persistence
        timestamp_str = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        safe_run_id = run_id.replace(":", "_").replace("-", "_")
        alert_filename = f"{timestamp_str}_{status.lower()}_{safe_run_id}.json"
        alert_path = self.alert_dir / alert_filename

        combined_record = {
            "metadata": {
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "run_id": run_id,
                "status": status,
                "stage": stage,
            },
            "generic": generic_payload,
            "slack": slack_payload,
            "teams": teams_payload,
        }

        with open(alert_path, "w", encoding="utf-8") as f:
            json.dump(combined_record, f, indent=2)

        # 2. Remote Webhook Dispatch (Graceful fallback)
        dispatch_results = {
            "persisted_path": str(alert_path),
            "slack_dispatched": False,
            "teams_dispatched": False,
            "generic_dispatched": False,
        }

        for channel, url, payload in [
            ("slack", self.slack_webhook_url, slack_payload),
            ("teams", self.teams_webhook_url, teams_payload),
            ("generic", self.generic_webhook_url, generic_payload),
        ]:
            if url:
                try:
                    req_data = json.dumps(payload).encode("utf-8")
                    req = urllib.request.Request(
                        url,
                        data=req_data,
                        headers={"Content-Type": "application/json; charset=utf-8"},
                        method="POST",
                    )
                    with urllib.request.urlopen(req, timeout=5) as response:
                        if 200 <= response.status < 300:
                            dispatch_results[f"{channel}_dispatched"] = True
                except Exception as ex:
                    dispatch_results[f"{channel}_error"] = str(ex)

        return dispatch_results

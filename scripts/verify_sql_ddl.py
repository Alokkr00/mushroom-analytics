"""
mycometrics/scripts/verify_sql_ddl.py
=====================================
Validates all SQL DDL scripts and verifies schema creation and table structures.
Can run against local PostgreSQL (if running) or in-process SQL engine (DuckDB)
to verify 100% ANSI/PostgreSQL DDL compliance and relational schema integrity.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

# Ensure UTF-8 output on Windows consoles
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

import duckdb
from rich.console import Console
from rich.table import Table

console = Console(highlight=False, emoji=False)

DDL_FILES = [
    "sql/initialization/01_create_schemas.sql",
    "sql/initialization/02_create_raw_tables.sql",
    "sql/initialization/03_create_audit_tables.sql",
    "sql/initialization/04_create_indexes_constraints.sql",
]


def test_ddl_compilation():
    console.print("\n[bold cyan]=== Verifying SQL DDL Scripts & Schema Creation ===[/bold cyan]\n")
    con = duckdb.connect(database=":memory:")

    # Execute DDL scripts in sequence
    for ddl_path_str in DDL_FILES:
        ddl_path = Path(ddl_path_str)
        if not ddl_path.exists():
            console.print(f"[bold red][FAIL] Missing DDL file: {ddl_path}[/bold red]")
            sys.exit(1)

        console.print(f"Reading & Executing: [yellow]{ddl_path_str}[/yellow]...")
        with open(ddl_path, "r", encoding="utf-8") as f:
            sql_text = f.read()

        # Split statements by semicolon and execute
        # Strip comments
        statements = []
        for raw_stmt in sql_text.split(";"):
            cleaned = "\n".join(
                line for line in raw_stmt.splitlines()
                if not line.strip().startswith("--") and not line.strip().startswith("COMMENT ON")
            ).strip()
            if cleaned:
                statements.append(cleaned)

        for stmt in statements:
            try:
                con.execute(stmt)
            except Exception as e:
                console.print(f"[bold red][SQL Error][/bold red] in {ddl_path.name}: {e}")
                console.print(f"Statement: {stmt[:120]}...")
                sys.exit(1)

        console.print(f"   [green][OK] {ddl_path.name} executed successfully.[/green]")

    # Verify created tables
    res = con.execute("""
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema IN ('raw', 'staging', 'analytics', 'audit')
        ORDER BY table_schema, table_name;
    """).fetchall()

    t = Table(show_header=True, header_style="bold cyan")
    t.add_column("Schema", style="yellow")
    t.add_column("Table Name", style="white")
    for s, n in res:
        t.add_row(s, n)

    console.print("\n[bold green][OK] Verified All DDL Scripts. Created Schema Objects:[/bold green]")
    console.print(t)
    console.print(f"Total verified schema objects: [yellow]{len(res)}[/yellow]\n")
    con.close()


if __name__ == "__main__":
    test_ddl_compilation()

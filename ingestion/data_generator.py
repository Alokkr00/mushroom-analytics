"""
mycometrics/ingestion/data_generator.py
========================================
Deterministic parametric synthetic data generator for FungiFlow Organics.

DESIGN PRINCIPLES
-----------------
1. Fixed random seed (default=42) guarantees 100% reproducibility.
2. Strict chronological ordering across all generated records.
3. Referential integrity: every foreign key resolves to a valid parent.
4. Biological plausibility: yields, cycle times, and shelf-lives obey real-world mycology.
5. Controlled edge-case injection: contaminated batches, spoilage events, short-fills,
   customer returns, duplicate invoice rows (for DQ testing).
6. Two scale presets:
     small  -> 6 months, ~35 batches, ~150 orders  (default / CI-safe)
     full   -> 18 months, ~180 batches, ~1500 orders
7. Every generated row carries `source_type = 'synthetic_demo'` (or 'synthetic_demo_DQ_TEST' for anomalies).
8. Pure ASCII console output for complete cross-platform Windows/Linux compatibility.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import os
import random
import sys
import uuid
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any

# Ensure UTF-8 output on Windows consoles if supported
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

import numpy as np
import pandas as pd
from rich.console import Console
from rich.table import Table

console = Console(highlight=False, emoji=False)

# ---------------------------------------------------------------------------
# CONSTANTS & REFERENCE TABLES
# ---------------------------------------------------------------------------

SOURCE_TYPE = "synthetic_demo"

# Mushroom varieties
MUSHROOM_VARIETIES = [
    {
        "mushroom_id": "MSH-01",
        "common_name": "Pearl Oyster",
        "scientific_name": "Pleurotus ostreatus",
        "substrate_formula": "Pasteurized Wheat Straw + 10% Wheat Bran",
        "incubation_days_min": 18,
        "incubation_days_max": 22,
        "days_to_flush1_min": 5,
        "days_to_flush1_max": 8,
        "days_between_flushes_min": 7,
        "days_between_flushes_max": 12,
        "be_min": 0.75,        # biological efficiency (fraction)
        "be_max": 1.10,
        "flush1_share_min": 0.60,   # flush 1's share of total BE
        "flush1_share_max": 0.70,
        "shelf_life_days": 5,
        "rejection_rate_normal_min": 0.02,
        "rejection_rate_normal_max": 0.06,
        "rejection_rate_stress_min": 0.15,
        "rejection_rate_stress_max": 0.28,
        "spawn_rate": 0.10,    # kg spawn per kg dry substrate
        "contamination_rate": 0.04,  # probability a batch is contaminated
        "introduced_month_offset": 0,  # available from Month 1
    },
    {
        "mushroom_id": "MSH-02",
        "common_name": "Lion's Mane",
        "scientific_name": "Hericium erinaceus",
        "substrate_formula": "Supplemented Hardwood Sawdust (Master's Mix)",
        "incubation_days_min": 24,
        "incubation_days_max": 30,
        "days_to_flush1_min": 10,
        "days_to_flush1_max": 14,
        "days_between_flushes_min": 10,
        "days_between_flushes_max": 14,
        "be_min": 0.60,
        "be_max": 0.85,
        "flush1_share_min": 0.62,
        "flush1_share_max": 0.72,
        "shelf_life_days": 7,
        "rejection_rate_normal_min": 0.03,
        "rejection_rate_normal_max": 0.07,
        "rejection_rate_stress_min": 0.18,
        "rejection_rate_stress_max": 0.30,
        "spawn_rate": 0.10,
        "contamination_rate": 0.06,
        "introduced_month_offset": 1,  # introduced in Month 2
    },
    {
        "mushroom_id": "MSH-03",
        "common_name": "Shiitake",
        "scientific_name": "Lentinula edodes",
        "substrate_formula": "Sterilized Supplemented Hardwood Sawdust",
        "incubation_days_min": 60,
        "incubation_days_max": 75,
        "days_to_flush1_min": 7,
        "days_to_flush1_max": 12,
        "days_between_flushes_min": 10,
        "days_between_flushes_max": 15,
        "be_min": 0.50,
        "be_max": 0.70,
        "flush1_share_min": 0.58,
        "flush1_share_max": 0.68,
        "shelf_life_days": 10,
        "rejection_rate_normal_min": 0.02,
        "rejection_rate_normal_max": 0.05,
        "rejection_rate_stress_min": 0.12,
        "rejection_rate_stress_max": 0.22,
        "spawn_rate": 0.10,
        "contamination_rate": 0.05,
        "introduced_month_offset": 2,  # initiated in Month 3
    },
]

# Finished Product SKUs
PRODUCT_CATALOG_TEMPLATE = [
    # (mushroom_id, sku_suffix, name_template, package_format, unit_weight_kg, grade, list_price_usd)
    ("MSH-01", "WHL-01KG", "{variety} Bulk Wholesale Crate 1 kg",  "Bulk Crate",        1.000, "Grade A", 16.00),
    ("MSH-01", "WHL-05KG", "{variety} Bulk Wholesale Crate 5 kg",  "Bulk Crate",        5.000, "Grade A", 15.00),
    ("MSH-01", "RTL-250G", "{variety} Retail Clamshell 250 g",     "Clamshell Punnet",  0.250, "Grade A",  5.00),
    ("MSH-01", "MKT-150G", "{variety} Farmers Market Bag 150 g",   "Kraft Paper Bag",   0.150, "Grade A",  3.50),
    ("MSH-01", "SEC-01KG", "{variety} Kitchen Seconds 1 kg",       "Bulk Crate",        1.000, "Grade B", 10.50),
    ("MSH-02", "WHL-01KG", "{variety} Bulk Wholesale Crate 1 kg",  "Bulk Crate",        1.000, "Grade A", 27.00),
    ("MSH-02", "RTL-200G", "{variety} Retail Clamshell 200 g",     "Clamshell Punnet",  0.200, "Grade A",  6.50),
    ("MSH-02", "MKT-150G", "{variety} Farmers Market Bag 150 g",   "Kraft Paper Bag",   0.150, "Grade A",  5.00),
    ("MSH-03", "WHL-01KG", "{variety} Bulk Wholesale Crate 1 kg",  "Bulk Crate",        1.000, "Grade A", 24.00),
    ("MSH-03", "WHL-02KG", "{variety} Bulk Wholesale Crate 2 kg",  "Bulk Crate",        2.000, "Grade A", 23.00),
    ("MSH-03", "RTL-200G", "{variety} Retail Clamshell 200 g",     "Clamshell Punnet",  0.200, "Grade A",  5.50),
    ("MSH-03", "DRY-100G", "{variety} Dried 100 g Retail Bag",     "Dried Retail Bag",  0.100, "Grade A",  8.00),
    ("MSH-03", "SEC-01KG", "{variety} Kitchen Seconds 1 kg",       "Bulk Crate",        1.000, "Grade B", 16.00),
]

# Customer accounts
CUSTOMER_TEMPLATES = [
    {"name": "Sage & Ember Restaurant",       "segment": "Restaurant",         "zone": "Zone A", "payment_terms": 14, "pref_variety": "MSH-02"},
    {"name": "The Umami Kitchen",             "segment": "Restaurant",         "zone": "Zone A", "payment_terms": 14, "pref_variety": "MSH-01"},
    {"name": "Fernwood Bistro",               "segment": "Restaurant",         "zone": "Zone B", "payment_terms": 7,  "pref_variety": "MSH-03"},
    {"name": "Harvest Table Co-op",           "segment": "Restaurant",         "zone": "Zone C", "payment_terms": 7,  "pref_variety": "MSH-01"},
    {"name": "Green Plate Farm Kitchen",      "segment": "Restaurant",         "zone": "Zone A", "payment_terms": 30, "pref_variety": "MSH-02"},
    {"name": "Verdant Greens Grocery",        "segment": "Boutique Grocer",    "zone": "Zone A", "payment_terms": 14, "pref_variety": "MSH-01"},
    {"name": "Wild Earth Market",             "segment": "Boutique Grocer",    "zone": "Zone B", "payment_terms": 14, "pref_variety": "MSH-03"},
    {"name": "The Good Pantry",               "segment": "Boutique Grocer",    "zone": "Zone C", "payment_terms": 30, "pref_variety": "MSH-02"},
    {"name": "Natural Roots Health Store",    "segment": "Boutique Grocer",    "zone": "Zone B", "payment_terms": 14, "pref_variety": "MSH-01"},
    {"name": "Sunrise Farmers Market Stall",  "segment": "Farmers Market",     "zone": "Zone A", "payment_terms": 0,  "pref_variety": "MSH-01"},
    {"name": "Weekend Community Market",      "segment": "Farmers Market",     "zone": "Zone C", "payment_terms": 0,  "pref_variety": "MSH-01"},
    {"name": "Ramen & Roots Noodle Bar",      "segment": "Restaurant",         "zone": "Zone B", "payment_terms": 14, "pref_variety": "MSH-01"},
    {"name": "Elena's Home Kitchen",          "segment": "Direct Consumer",    "zone": "Zone A", "payment_terms": 0,  "pref_variety": "MSH-02"},
    {"name": "Marcus D'Souza",                "segment": "Direct Consumer",    "zone": "Zone B", "payment_terms": 0,  "pref_variety": "MSH-03"},
    {"name": "Priya Wellness Kitchen",        "segment": "Direct Consumer",    "zone": "Zone A", "payment_terms": 0,  "pref_variety": "MSH-01"},
    {"name": "Cloudforest Soup Co.",          "segment": "Restaurant",         "zone": "Zone C", "payment_terms": 7,  "pref_variety": "MSH-01"},
    {"name": "Bloom & Root Cafe",             "segment": "Restaurant",         "zone": "Zone A", "payment_terms": 14, "pref_variety": "MSH-02"},
    {"name": "Anchor & Grain Diner",          "segment": "Restaurant",         "zone": "Zone B", "payment_terms": 14, "pref_variety": "MSH-03"},
    {"name": "Terra Firma Wellness",          "segment": "Boutique Grocer",    "zone": "Zone C", "payment_terms": 30, "pref_variety": "MSH-01"},
    {"name": "Sunday Table Market",           "segment": "Farmers Market",     "zone": "Zone A", "payment_terms": 0,  "pref_variety": "MSH-01"},
]

# Suppliers
SUPPLIERS = [
    {"supplier_id": "SUP-01", "name": "MycoSpawn Labs",        "category": "Grain Spawn",       "lead_days_min": 3, "lead_days_max": 6,  "payment_terms": 30},
    {"supplier_id": "SUP-02", "name": "AgroStraw Direct",       "category": "Substrate",          "lead_days_min": 1, "lead_days_max": 3,  "payment_terms": 14},
    {"supplier_id": "SUP-03", "name": "HardWood Pellets Co.",   "category": "Substrate",          "lead_days_min": 2, "lead_days_max": 5,  "payment_terms": 14},
    {"supplier_id": "SUP-04", "name": "SoyHull Agri Supplies",  "category": "Substrate",          "lead_days_min": 3, "lead_days_max": 7,  "payment_terms": 30},
    {"supplier_id": "SUP-05", "name": "ClearPack Solutions",    "category": "Packaging",          "lead_days_min": 2, "lead_days_max": 4,  "payment_terms": 14},
    {"supplier_id": "SUP-06", "name": "FilterBag Supply Co.",   "category": "Packaging",          "lead_days_min": 3, "lead_days_max": 6,  "payment_terms": 14},
    {"supplier_id": "SUP-07", "name": "City Power & Utilities", "category": "Utilities",          "lead_days_min": 0, "lead_days_max": 0,  "payment_terms": 30},
    {"supplier_id": "SUP-08", "name": "Green Facility Leasing", "category": "Rent",               "lead_days_min": 0, "lead_days_max": 0,  "payment_terms": 30},
    {"supplier_id": "SUP-09", "name": "CleanPro Hygiene Dist.", "category": "Hygiene & Consumables","lead_days_min": 2, "lead_days_max": 3, "payment_terms": 14},
    {"supplier_id": "SUP-10", "name": "FreshRoute Courier",    "category": "Transport",           "lead_days_min": 0, "lead_days_max": 0,  "payment_terms": 7},
]

# Growing rooms and storage locations
LOCATIONS = [
    {"location_id": "LOC-01", "name": "Grow Room A",         "capacity_blocks": 200, "temp_controlled": True},
    {"location_id": "LOC-02", "name": "Grow Room B",         "capacity_blocks": 200, "temp_controlled": True},
    {"location_id": "LOC-03", "name": "Incubation Darkroom", "capacity_blocks": 400, "temp_controlled": True},
    {"location_id": "LOC-04", "name": "Walk-in Chiller",     "capacity_blocks": 0,   "temp_controlled": True},
    {"location_id": "LOC-05", "name": "Substrate Prep Area", "capacity_blocks": 0,   "temp_controlled": False},
]

# Chart-of-accounts expense categories
EXPENSE_CATEGORIES = [
    {"category_id": "EXP-01", "name": "Grain Spawn Purchase",   "behavior": "Direct Production",   "fs_section": "COGS"},
    {"category_id": "EXP-02", "name": "Substrate Materials",    "behavior": "Direct Production",   "fs_section": "COGS"},
    {"category_id": "EXP-03", "name": "Filter Patch Bags",      "behavior": "Direct Production",   "fs_section": "COGS"},
    {"category_id": "EXP-04", "name": "Direct Harvest Labor",   "behavior": "Direct Production",   "fs_section": "COGS"},
    {"category_id": "EXP-05", "name": "Packaging Materials",    "behavior": "Variable Operating",  "fs_section": "Operating Expense"},
    {"category_id": "EXP-06", "name": "Hygiene & Sanitization", "behavior": "Variable Operating",  "fs_section": "Operating Expense"},
    {"category_id": "EXP-07", "name": "Local Delivery & Fuel",  "behavior": "Variable Operating",  "fs_section": "Operating Expense"},
    {"category_id": "EXP-08", "name": "Electricity",            "behavior": "Fixed Overhead",       "fs_section": "Operating Expense"},
    {"category_id": "EXP-09", "name": "Water & Utilities",      "behavior": "Fixed Overhead",       "fs_section": "Operating Expense"},
    {"category_id": "EXP-10", "name": "Facility Rent",          "behavior": "Fixed Overhead",       "fs_section": "Operating Expense"},
    {"category_id": "EXP-11", "name": "Equipment Maintenance",  "behavior": "Fixed Overhead",       "fs_section": "Operating Expense"},
    {"category_id": "EXP-12", "name": "Business Insurance",     "behavior": "Fixed Overhead",       "fs_section": "Operating Expense"},
    {"category_id": "EXP-13", "name": "Marketing & Market Fees","behavior": "Variable Operating",   "fs_section": "Operating Expense"},
    {"category_id": "EXP-14", "name": "Miscellaneous Admin",    "behavior": "Fixed Overhead",       "fs_section": "Operating Expense"},
]

# ---------------------------------------------------------------------------
# SCALE PRESETS
# ---------------------------------------------------------------------------
SCALE_PRESETS: dict[str, dict] = {
    "small": {
        "months": 6,
        "batches_per_month_min": 4,
        "batches_per_month_max": 7,
        "blocks_per_batch_min": 20,
        "blocks_per_batch_max": 60,
        "dry_substrate_kg_per_block": 1.0,
        "orders_per_week_min": 3,
        "orders_per_week_max": 8,
        "inject_contaminated_batches": 3,
        "inject_stress_batches": 4,
        "inject_duplicate_invoices": 2,
        "inject_partial_orders": 5,
        "inject_customer_returns": 3,
    },
    "full": {
        "months": 18,
        "batches_per_month_min": 8,
        "batches_per_month_max": 14,
        "blocks_per_batch_min": 40,
        "blocks_per_batch_max": 120,
        "dry_substrate_kg_per_block": 1.0,
        "orders_per_week_min": 8,
        "orders_per_week_max": 20,
        "inject_contaminated_batches": 8,
        "inject_stress_batches": 12,
        "inject_duplicate_invoices": 6,
        "inject_partial_orders": 15,
        "inject_customer_returns": 10,
    },
}

# ---------------------------------------------------------------------------
# HELPER UTILITIES
# ---------------------------------------------------------------------------

def make_id(prefix: str, counter: int) -> str:
    return f"{prefix}{counter:05d}"


def randdate(rng: random.Random, start: date, end: date) -> date:
    delta = (end - start).days
    return start + timedelta(days=rng.randint(0, max(0, delta)))


def ts(d: date) -> str:
    """Return ISO 8601 UTC datetime string for a given date."""
    return datetime(d.year, d.month, d.day, 0, 0, 0).strftime("%Y-%m-%dT%H:%M:%SZ")


def clamp(value: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, value))


# ---------------------------------------------------------------------------
# GENERATOR CLASS
# ---------------------------------------------------------------------------

class MycoDataGenerator:
    """
    Generates all synthetic operational datasets for FungiFlow Organics.
    """

    def __init__(self, scale: str = "small", seed: int = 42):
        if scale not in SCALE_PRESETS:
            raise ValueError(f"scale must be one of {list(SCALE_PRESETS)}; got '{scale}'")

        self.scale = scale
        self.cfg = SCALE_PRESETS[scale]
        self.seed = seed

        self.rng = random.Random(seed)
        self.np_rng = np.random.default_rng(seed)

        self.start_date = date(2024, 5, 1)
        self.end_date = self.start_date + timedelta(days=30 * self.cfg["months"])

        self.mushroom_varieties: list[dict] = []
        self.locations: list[dict] = []
        self.expense_categories: list[dict] = []
        self.products: list[dict] = []
        self.suppliers: list[dict] = []
        self.customers: list[dict] = []
        self.production_batches: list[dict] = []
        self.harvest_records: list[dict] = []
        self.inventory_movements: list[dict] = []
        self.sales_orders: list[dict] = []
        self.sales_order_lines: list[dict] = []
        self.expenses: list[dict] = []
        self.purchases: list[dict] = []
        self.waste_events: list[dict] = []
        self.returns: list[dict] = []

        self._batch_counter = 1
        self._harvest_counter = 1
        self._movement_counter = 1
        self._order_counter = 1
        self._line_counter = 1
        self._expense_counter = 1
        self._purchase_counter = 1
        self._waste_counter = 1
        self._return_counter = 1

        self._lot_stock: dict[str, float] = {}
        self._lot_meta: dict[str, dict] = {}
        self._batch_meta: dict[str, dict] = {}
        self._completed_lines: list[dict] = []

    def generate(self) -> "MycoDataGenerator":
        console.print("\n[bold cyan]=== MycoMetrics Data Generator ===[/bold cyan]")
        console.print(f"   Scale: [yellow]{self.scale}[/yellow]  |  Seed: [yellow]{self.seed}[/yellow]")
        console.print(f"   Period: [yellow]{self.start_date}[/yellow] to [yellow]{self.end_date}[/yellow]\n")

        self._build_reference_tables()
        self._generate_batches_and_harvests()
        self._generate_sales_cycle()
        self._generate_expenses()
        self._generate_purchases()
        self._inject_waste_events()
        self._inject_customer_returns()
        self._apply_data_quality_anomalies()

        self._print_summary()
        return self

    def _build_reference_tables(self) -> None:
        console.print("[bold]Step 1/7[/bold] Building reference tables...")

        for v in MUSHROOM_VARIETIES:
            self.mushroom_varieties.append({
                **v,
                "source_type": SOURCE_TYPE,
                "created_at": ts(self.start_date),
            })

        for loc in LOCATIONS:
            self.locations.append({**loc, "source_type": SOURCE_TYPE, "created_at": ts(self.start_date)})

        for ec in EXPENSE_CATEGORIES:
            self.expense_categories.append({**ec, "source_type": SOURCE_TYPE, "created_at": ts(self.start_date)})

        for sup in SUPPLIERS:
            self.suppliers.append({**sup, "source_type": SOURCE_TYPE, "created_at": ts(self.start_date)})

        sku_counter = 1
        variety_map = {v["mushroom_id"]: v for v in MUSHROOM_VARIETIES}
        for tmpl in PRODUCT_CATALOG_TEMPLATE:
            msh_id, sku_suffix, name_tmpl, pkg_fmt, unit_wt, grade, price = tmpl
            variety = variety_map[msh_id]
            self.products.append({
                "product_id": f"PRD-{sku_counter:03d}",
                "mushroom_id": msh_id,
                "sku_code": f"{msh_id}-{sku_suffix}",
                "product_name": name_tmpl.replace("{variety}", variety["common_name"]),
                "package_format": pkg_fmt,
                "unit_weight_kg": unit_wt,
                "grade": grade,
                "standard_selling_price": price,
                "active_status": True,
                "source_type": SOURCE_TYPE,
                "created_at": ts(self.start_date),
            })
            sku_counter += 1

        acq_base = self.start_date
        for i, c in enumerate(CUSTOMER_TEMPLATES):
            acq_offset = self.rng.randint(0, min(60, (self.end_date - self.start_date).days))
            acq_date = acq_base + timedelta(days=acq_offset)
            self.customers.append({
                "customer_id": f"CUS-{i+1:03d}",
                "customer_name": c["name"],
                "customer_segment": c["segment"],
                "delivery_route_zone": c["zone"],
                "payment_terms_days": c["payment_terms"],
                "preferred_variety": c.get("pref_variety", ""),
                "acquisition_date": acq_date.isoformat(),
                "is_active": True,
                "source_type": SOURCE_TYPE,
                "created_at": ts(acq_date),
            })

        console.print(f"   [green][OK][/green] Varieties: {len(self.mushroom_varieties)}  Products: {len(self.products)}  "
                      f"Customers: {len(self.customers)}  Suppliers: {len(self.suppliers)}")

    def _generate_batches_and_harvests(self) -> None:
        console.print("[bold]Step 2/7[/bold] Generating batches & harvest records...")

        cfg = self.cfg
        variety_map = {v["mushroom_id"]: v for v in MUSHROOM_VARIETIES}
        room_ids = ["LOC-01", "LOC-02"]

        all_batch_numbers = list(range(1, 200))
        self.rng.shuffle(all_batch_numbers)
        contaminated_slots = set(all_batch_numbers[:cfg["inject_contaminated_batches"]])
        stress_slots = set(all_batch_numbers[cfg["inject_contaminated_batches"]:
                                             cfg["inject_contaminated_batches"] + cfg["inject_stress_batches"]])

        batch_seq = 0

        for month_offset in range(cfg["months"]):
            month_start = self.start_date + timedelta(days=30 * month_offset)
            active_varieties = [
                v for v in MUSHROOM_VARIETIES
                if v["introduced_month_offset"] <= month_offset
            ]

            n_batches = self.rng.randint(cfg["batches_per_month_min"], cfg["batches_per_month_max"])

            for _ in range(n_batches):
                batch_seq += 1
                batch_id = make_id("BAT-", self._batch_counter)
                self._batch_counter += 1

                variety = self.rng.choice(active_varieties)
                msh_id = variety["mushroom_id"]
                v_cfg = variety_map[msh_id]

                batch_start = randdate(self.rng, month_start, month_start + timedelta(days=28))
                if batch_start > self.end_date:
                    continue

                n_blocks = self.rng.randint(cfg["blocks_per_batch_min"], cfg["blocks_per_batch_max"])
                dry_substrate_kg = round(n_blocks * cfg["dry_substrate_kg_per_block"], 3)
                spawn_kg = round(dry_substrate_kg * v_cfg["spawn_rate"], 3)
                water_liters = round(dry_substrate_kg * 1.5, 1)

                substrate_unit_cost = self.rng.uniform(0.80, 1.20)
                spawn_unit_cost = self.rng.uniform(8.0, 12.0)
                bag_unit_cost = 0.45
                direct_batch_material_cost = round(
                    dry_substrate_kg * substrate_unit_cost
                    + spawn_kg * spawn_unit_cost
                    + n_blocks * bag_unit_cost,
                    2
                )

                is_contaminated = batch_seq in contaminated_slots
                is_stress = batch_seq in stress_slots

                incubation_days = self.rng.randint(v_cfg["incubation_days_min"], v_cfg["incubation_days_max"])
                transfer_date = batch_start + timedelta(days=incubation_days)

                mid_be = (v_cfg["be_min"] + v_cfg["be_max"]) / 2
                target_yield_kg = round(dry_substrate_kg * mid_be, 3)
                room_id = self.rng.choice(room_ids)
                batch_status = "CONTAMINATED" if is_contaminated else "COMPLETED"

                exp_harvest_days = v_cfg["days_to_flush1_min"] + (v_cfg["days_to_flush1_max"] - v_cfg["days_to_flush1_min"]) // 2
                expected_first_harvest_date = transfer_date + timedelta(days=exp_harvest_days)

                batch_rec = {
                    "batch_id": batch_id,
                    "mushroom_id": msh_id,
                    "mushroom_variety": v_cfg["common_name"],
                    "substrate_formula": v_cfg["substrate_formula"],
                    "planned_blocks_count": n_blocks,
                    "dry_substrate_kg": dry_substrate_kg,
                    "water_liters_added": water_liters,
                    "spawn_kg": spawn_kg,
                    "batch_start_date": batch_start.isoformat(),
                    "transfer_to_fruiting_date": transfer_date.isoformat(),
                    "growing_room_id": room_id,
                    "expected_first_harvest_date": expected_first_harvest_date.isoformat(),
                    "target_yield_kg": target_yield_kg,
                    "direct_material_cost": direct_batch_material_cost,
                    "batch_status": batch_status,
                    "is_stress_event": is_stress,
                    "notes": (
                        "CONTAMINATED BATCH: Trichoderma mould detected. Entire batch discarded."
                        if is_contaminated
                        else ("STRESS EVENT: High humidity spike recorded mid-fruiting." if is_stress else "")
                    ),
                    "source_type": SOURCE_TYPE,
                    "created_at": ts(batch_start),
                }
                self.production_batches.append(batch_rec)

                self._batch_meta[batch_id] = {
                    "msh_id": msh_id,
                    "variety_cfg": v_cfg,
                    "is_contaminated": is_contaminated,
                    "is_stress": is_stress,
                    "batch_start": batch_start,
                    "transfer_date": transfer_date,
                    "dry_substrate_kg": dry_substrate_kg,
                    "n_blocks": n_blocks,
                    "direct_material_cost": direct_batch_material_cost,
                }

                if not is_contaminated:
                    self._generate_harvest_flushes(batch_id, batch_rec)

        console.print(f"   [green][OK][/green] Batches: {len(self.production_batches)}  "
                      f"(Contaminated: {sum(1 for b in self.production_batches if b['batch_status']=='CONTAMINATED')}, "
                      f"Stress: {sum(1 for b in self.production_batches if b['is_stress_event'])})")
        console.print(f"   [green][OK][/green] Harvest records: {len(self.harvest_records)}  "
                      f"Inventory lots: {len(self._lot_stock)}")

    def _generate_harvest_flushes(self, batch_id: str, batch: dict) -> None:
        meta = self._batch_meta[batch_id]
        v_cfg = meta["variety_cfg"]
        is_stress = meta["is_stress"]
        dry_substrate_kg = meta["dry_substrate_kg"]
        transfer_date = meta["transfer_date"]

        be = self.rng.uniform(v_cfg["be_min"], v_cfg["be_max"])
        if is_stress:
            be *= self.rng.uniform(0.55, 0.75)
        be = clamp(be, 0.20, 1.20)

        total_yield_kg = dry_substrate_kg * be
        f1_days = self.rng.randint(v_cfg["days_to_flush1_min"], v_cfg["days_to_flush1_max"])
        flush1_date = transfer_date + timedelta(days=f1_days)
        if flush1_date > self.end_date:
            return

        f1_share = self.rng.uniform(v_cfg["flush1_share_min"], v_cfg["flush1_share_max"])
        flush1_gross_kg = round(total_yield_kg * f1_share, 3)
        flush2_gross_kg = round(total_yield_kg * (1.0 - f1_share), 3)

        if is_stress:
            rej_rate = self.rng.uniform(v_cfg["rejection_rate_stress_min"], v_cfg["rejection_rate_stress_max"])
        else:
            rej_rate = self.rng.uniform(v_cfg["rejection_rate_normal_min"], v_cfg["rejection_rate_normal_max"])

        f2_days = f1_days + self.rng.randint(v_cfg["days_between_flushes_min"], v_cfg["days_between_flushes_max"])
        flush2_date = transfer_date + timedelta(days=f2_days)

        for flush_num, (flush_date, gross_kg) in enumerate(
            [(flush1_date, flush1_gross_kg), (flush2_date, flush2_gross_kg)],
            start=1
        ):
            if flush_date > self.end_date or gross_kg <= 0:
                continue

            rejected_kg = round(gross_kg * rej_rate, 3)
            accepted_kg = round(gross_kg - rejected_kg, 3)

            harvest_id = make_id("HRV-", self._harvest_counter)
            self._harvest_counter += 1

            rejection_reason = ""
            if rejected_kg > 0:
                reasons = ["Bacterial blotch", "Spore drop contamination", "Physical bruising",
                           "Dehydration/Shrinkage", "Insect damage", "Abnormal growth form"]
                rejection_reason = self.rng.choice(reasons) if is_stress else self.rng.choice(reasons[:3])

            labor_hours = round(accepted_kg * self.rng.uniform(0.25, 0.45), 2)

            harvest_rec = {
                "harvest_id": harvest_id,
                "batch_id": batch_id,
                "harvest_date": flush_date.isoformat(),
                "flush_number": flush_num,
                "gross_harvested_kg": gross_kg,
                "accepted_weight_kg": accepted_kg,
                "rejected_weight_kg": rejected_kg,
                "rejection_reason": rejection_reason,
                "labor_hours": labor_hours,
                "source_type": SOURCE_TYPE,
                "recorded_at": ts(flush_date),
            }
            self.harvest_records.append(harvest_rec)

            if accepted_kg > 0:
                self._create_inventory_lot(harvest_id, batch_id, flush_date, accepted_kg, meta)

    def _create_inventory_lot(self, harvest_id: str, batch_id: str, harvest_date: date,
                               accepted_kg: float, meta: dict) -> None:
        msh_id = meta["msh_id"]
        v_cfg = meta["variety_cfg"]

        bulk_product = next(
            (p for p in self.products
             if p["mushroom_id"] == msh_id and p["package_format"] == "Bulk Crate" and p["grade"] == "Grade A"),
            None
        )
        if bulk_product is None:
            return

        product_id = bulk_product["product_id"]
        expiry_date = harvest_date + timedelta(days=v_cfg["shelf_life_days"])
        estimated_unit_cost = round(
            meta["direct_material_cost"] / max(1, accepted_kg) * (1 / 0.70),
            4
        )

        lot_id = make_id("LOT-", self._movement_counter)
        movement_id = make_id("MOV-", self._movement_counter)
        self._movement_counter += 1

        self.inventory_movements.append({
            "movement_id": movement_id,
            "lot_id": lot_id,
            "product_id": product_id,
            "mushroom_id": msh_id,
            "batch_id": batch_id,
            "harvest_id": harvest_id,
            "movement_date": harvest_date.isoformat(),
            "movement_type": "HARVEST_IN",
            "signed_quantity_kg": accepted_kg,
            "unit_cost": estimated_unit_cost,
            "total_movement_value": round(accepted_kg * estimated_unit_cost, 2),
            "expiry_date": expiry_date.isoformat(),
            "reason": "Fresh harvest receipt into cold storage",
            "reference_transaction_id": harvest_id,
            "source_type": SOURCE_TYPE,
            "created_at": ts(harvest_date),
        })

        self._lot_stock[lot_id] = accepted_kg
        self._lot_meta[lot_id] = {
            "product_id": product_id,
            "mushroom_id": msh_id,
            "batch_id": batch_id,
            "harvest_date": harvest_date,
            "expiry_date": expiry_date,
            "unit_cost": estimated_unit_cost,
        }

    def _generate_sales_cycle(self) -> None:
        console.print("[bold]Step 3/7[/bold] Generating sales orders & order lines...")

        cfg = self.cfg
        product_map = {p["product_id"]: p for p in self.products}
        customer_list = self.customers
        variety_map = {v["mushroom_id"]: v for v in MUSHROOM_VARIETIES}

        current_date = self.start_date
        n_partial_injections = cfg["inject_partial_orders"]
        partial_injected = 0

        while current_date <= self.end_date:
            week_end = current_date + timedelta(days=6)
            n_orders_this_week = self.rng.randint(cfg["orders_per_week_min"], cfg["orders_per_week_max"])

            for _ in range(n_orders_this_week):
                order_date = randdate(self.rng, current_date, min(week_end, self.end_date))

                available_lots = {
                    lot_id: qty
                    for lot_id, qty in self._lot_stock.items()
                    if qty > 0.005
                    and self._lot_meta[lot_id]["harvest_date"] <= order_date
                    and self._lot_meta[lot_id]["expiry_date"] > order_date
                }
                if not available_lots:
                    continue

                customer = self.rng.choice(customer_list)
                cust_id = customer["customer_id"]
                channel_map = {
                    "Restaurant": "Wholesale Direct",
                    "Boutique Grocer": "Wholesale Direct",
                    "Farmers Market": "Market Direct",
                    "Direct Consumer": "D2C",
                }
                channel = channel_map.get(customer["customer_segment"], "Other")

                lead_time = self.rng.randint(1, 3)
                requested_delivery = order_date + timedelta(days=lead_time)
                actual_delivery = requested_delivery + timedelta(days=self.rng.choice([0, 0, 0, 1]))

                order_id = make_id("ORD-", self._order_counter)
                self._order_counter += 1

                order_rec = {
                    "order_id": order_id,
                    "customer_id": cust_id,
                    "order_date": order_date.isoformat(),
                    "requested_delivery_date": requested_delivery.isoformat(),
                    "actual_delivery_date": actual_delivery.isoformat(),
                    "order_status": "COMPLETED",
                    "payment_status": "PAID" if self.rng.random() > 0.12 else "OUTSTANDING",
                    "sales_channel": channel,
                    "source_type": SOURCE_TYPE,
                    "created_at": ts(order_date),
                }
                self.sales_orders.append(order_rec)

                n_lines = self.rng.randint(1, 4)
                lots_used = list(available_lots.keys())
                self.rng.shuffle(lots_used)

                for lot_id in lots_used[:n_lines]:
                    lot = self._lot_meta[lot_id]
                    product_id = lot["product_id"]
                    product = product_map.get(product_id)
                    if product is None:
                        continue

                    msh_id = lot["mushroom_id"]

                    if customer["customer_segment"] in ("Restaurant", "Boutique Grocer"):
                        qty_ordered = round(self.rng.uniform(1.0, 10.0), 3)
                    else:
                        qty_ordered = round(self.rng.uniform(0.15, 1.5), 3)

                    inject_partial = (partial_injected < n_partial_injections
                                      and self.rng.random() < 0.25)

                    available_qty = self._lot_stock[lot_id]
                    if qty_ordered > available_qty:
                        qty_fulfilled = round(available_qty, 3)
                    elif inject_partial:
                        qty_fulfilled = round(qty_ordered * self.rng.uniform(0.3, 0.8), 3)
                        partial_injected += 1
                    else:
                        qty_fulfilled = qty_ordered

                    qty_fulfilled = max(0.0, qty_fulfilled)
                    unit_price = product["standard_selling_price"]

                    if qty_fulfilled >= 5.0 and customer["customer_segment"] == "Restaurant":
                        discount_pct = self.rng.uniform(0.05, 0.12)
                    else:
                        discount_pct = 0.0

                    discount_amt = round(qty_fulfilled * unit_price * discount_pct, 2)
                    gross_revenue = round(qty_fulfilled * unit_price, 2)
                    net_revenue = round(gross_revenue - discount_amt, 2)

                    line_id = make_id("LIN-", self._line_counter)
                    self._line_counter += 1

                    line_rec = {
                        "order_line_id": line_id,
                        "order_id": order_id,
                        "product_id": product_id,
                        "mushroom_id": msh_id,
                        "lot_id": lot_id,
                        "quantity_ordered_kg": qty_ordered,
                        "quantity_fulfilled_kg": qty_fulfilled,
                        "unit_of_measure": "kg",
                        "unit_selling_price": unit_price,
                        "discount_amount": discount_amt,
                        "gross_revenue": gross_revenue,
                        "net_revenue": net_revenue,
                        "source_type": SOURCE_TYPE,
                        "created_at": ts(order_date),
                    }
                    self.sales_order_lines.append(line_rec)
                    self._completed_lines.append(line_rec)

                    if qty_fulfilled > 0:
                        self._lot_stock[lot_id] = round(max(0.0, self._lot_stock[lot_id] - qty_fulfilled), 3)

                        mov_id = make_id("MOV-", self._movement_counter)
                        self._movement_counter += 1
                        self.inventory_movements.append({
                            "movement_id": mov_id,
                            "lot_id": lot_id,
                            "product_id": product_id,
                            "mushroom_id": msh_id,
                            "batch_id": lot["batch_id"],
                            "harvest_id": "",
                            "movement_date": actual_delivery.isoformat(),
                            "movement_type": "SALE_OUT",
                            "signed_quantity_kg": -qty_fulfilled,
                            "unit_cost": lot["unit_cost"],
                            "total_movement_value": round(-qty_fulfilled * lot["unit_cost"], 2),
                            "expiry_date": lot["expiry_date"].isoformat(),
                            "reason": f"Customer order {order_id}",
                            "reference_transaction_id": line_id,
                            "source_type": SOURCE_TYPE,
                            "created_at": ts(actual_delivery),
                        })

            current_date += timedelta(days=7)

        console.print(f"   [green][OK][/green] Orders: {len(self.sales_orders)}  Lines: {len(self.sales_order_lines)}")

    def _generate_expenses(self) -> None:
        console.print("[bold]Step 4/7[/bold] Generating expense records...")

        for month_offset in range(self.cfg["months"]):
            month_start = self.start_date + timedelta(days=30 * month_offset)

            fixed_items = [
                ("EXP-10", "SUP-08", "Facility lease - monthly rent",          1200.00, 0.0),
                ("EXP-08", "SUP-07", "Electricity - fruiting room cooling/fans",
                 self.rng.uniform(350, 550), 0.02),
                ("EXP-09", "SUP-07", "Water utility bill",                     self.rng.uniform(55, 75), 0.0),
                ("EXP-12", None,     "Commercial liability insurance - monthly", 95.00, 0.0),
                ("EXP-14", None,     "Miscellaneous admin (phone, internet)",   self.rng.uniform(60, 90), 0.0),
            ]
            for cat_id, sup_id, desc, base_amt, noise_pct in fixed_items:
                amt = round(base_amt * (1 + self.rng.uniform(-noise_pct, noise_pct)), 2)
                exp_date = month_start + timedelta(days=self.rng.randint(1, 5))
                exp_id = make_id("EXP-", self._expense_counter)
                self._expense_counter += 1
                self.expenses.append({
                    "expense_id": exp_id,
                    "expense_date": exp_date.isoformat(),
                    "expense_category_id": cat_id,
                    "description": desc,
                    "amount": amt,
                    "currency": "USD",
                    "supplier_id": sup_id or "",
                    "batch_id": "",
                    "allocation_method": "Fixed Monthly",
                    "source_type": SOURCE_TYPE,
                    "created_at": ts(exp_date),
                })

            n_var = self.rng.randint(2, 5)
            var_items = [
                ("EXP-05", "SUP-05", "Clamshell punnets & kraft bags bulk purchase", (80, 200)),
                ("EXP-06", "SUP-09", "Isopropyl alcohol, bleach, gloves, disposables", (30, 70)),
                ("EXP-07", "SUP-10", "Delivery fuel / courier charges", (25, 90)),
                ("EXP-11", None,     "Equipment calibration & maintenance", (20, 120)),
                ("EXP-13", None,     "Market stall fee / social media boost", (15, 60)),
            ]
            for _ in range(n_var):
                cat_id, sup_id, desc, (lo, hi) = self.rng.choice(var_items)
                amt = round(self.rng.uniform(lo, hi), 2)
                exp_date = randdate(self.rng, month_start, month_start + timedelta(days=28))
                exp_id = make_id("EXP-", self._expense_counter)
                self._expense_counter += 1
                self.expenses.append({
                    "expense_id": exp_id,
                    "expense_date": exp_date.isoformat(),
                    "expense_category_id": cat_id,
                    "description": desc,
                    "amount": amt,
                    "currency": "USD",
                    "supplier_id": sup_id or "",
                    "batch_id": "",
                    "allocation_method": "Variable Period",
                    "source_type": SOURCE_TYPE,
                    "created_at": ts(exp_date),
                })

        console.print(f"   [green][OK][/green] Expense records: {len(self.expenses)}")

    def _generate_purchases(self) -> None:
        console.print("[bold]Step 5/7[/bold] Generating procurement records...")

        material_config = [
            ("SUP-01", "Grain Spawn (Rye Berries, Sterilized)", "kg", (9.0, 13.0), (1.0, 5.0)),
            ("SUP-02", "Wheat Straw (Chopped)", "kg", (0.40, 0.70), (20.0, 80.0)),
            ("SUP-03", "Hardwood Sawdust Pellets", "kg", (0.60, 0.90), (15.0, 60.0)),
            ("SUP-04", "Soybean Hulls", "kg", (0.80, 1.10), (10.0, 40.0)),
            ("SUP-05", "Clamshell Punnets (200g)", "units", (0.18, 0.26), (100, 400)),
            ("SUP-05", "Clamshell Punnets (250g)", "units", (0.20, 0.28), (80, 350)),
            ("SUP-06", "Filter Patch Autoclave Bags", "units", (0.38, 0.55), (50, 200)),
        ]

        for month_offset in range(self.cfg["months"]):
            month_start = self.start_date + timedelta(days=30 * month_offset)
            n_purchases = self.rng.randint(3, 7)

            for _ in range(n_purchases):
                sup_id, material, unit, price_range, qty_range = self.rng.choice(material_config)
                supplier = next(s for s in self.suppliers if s["supplier_id"] == sup_id)
                lead_days = self.rng.randint(supplier["lead_days_min"], max(supplier["lead_days_min"], supplier["lead_days_max"]))

                purchase_date = randdate(self.rng, month_start, month_start + timedelta(days=20))
                delivery_date = purchase_date + timedelta(days=lead_days)

                qty_ordered = round(self.rng.uniform(*qty_range), 2)
                if self.rng.random() < 0.08:
                    qty_received = round(qty_ordered * self.rng.uniform(0.65, 0.90), 2)
                else:
                    qty_received = qty_ordered

                unit_price = round(self.rng.uniform(*price_range), 4)
                total_cost = round(qty_received * unit_price, 2)

                pur_id = make_id("PUR-", self._purchase_counter)
                self._purchase_counter += 1

                self.purchases.append({
                    "purchase_id": pur_id,
                    "supplier_id": sup_id,
                    "purchase_date": purchase_date.isoformat(),
                    "material_name": material,
                    "unit_of_measure": unit,
                    "quantity_ordered": qty_ordered,
                    "quantity_received": qty_received,
                    "unit_price": unit_price,
                    "total_cost": total_cost,
                    "delivery_date": delivery_date.isoformat(),
                    "payment_status": "PAID" if self.rng.random() > 0.10 else "OUTSTANDING",
                    "source_type": SOURCE_TYPE,
                    "created_at": ts(purchase_date),
                })

        console.print(f"   [green][OK][/green] Purchase records: {len(self.purchases)}")

    def _inject_waste_events(self) -> None:
        console.print("[bold]Step 6/7[/bold] Generating waste & spoilage events...")

        waste_reasons = [
            "Cold storage spoilage - shelf life exceeded",
            "Physical damage during packaging",
            "Bacterial blotch detected post-packing",
            "Over-order correction - unsold stock write-off",
            "Power interruption - chiller failure",
        ]

        for lot_id, remaining_kg in list(self._lot_stock.items()):
            lot = self._lot_meta[lot_id]
            if remaining_kg > 0.01 and lot["expiry_date"] <= self.end_date:
                if self.rng.random() < 0.65:
                    waste_kg = round(remaining_kg * self.rng.uniform(0.4, 1.0), 3)
                    waste_kg = min(waste_kg, remaining_kg)
                    waste_date = lot["expiry_date"] + timedelta(days=self.rng.randint(0, 2))
                    if waste_date > self.end_date:
                        waste_date = self.end_date

                    reason = self.rng.choice(waste_reasons)
                    waste_id = make_id("WST-", self._waste_counter)
                    self._waste_counter += 1

                    self.waste_events.append({
                        "waste_id": waste_id,
                        "lot_id": lot_id,
                        "product_id": lot["product_id"],
                        "mushroom_id": lot["mushroom_id"],
                        "batch_id": lot["batch_id"],
                        "waste_date": waste_date.isoformat(),
                        "waste_type": "COLD_STORAGE_SPOILAGE",
                        "waste_kg": waste_kg,
                        "estimated_unit_cost": lot["unit_cost"],
                        "estimated_waste_value": round(waste_kg * lot["unit_cost"], 2),
                        "reason_code": reason,
                        "disposition": "Composted",
                        "source_type": SOURCE_TYPE,
                        "created_at": ts(waste_date),
                    })

                    self._lot_stock[lot_id] = round(max(0.0, remaining_kg - waste_kg), 3)

                    mov_id = make_id("MOV-", self._movement_counter)
                    self._movement_counter += 1
                    self.inventory_movements.append({
                        "movement_id": mov_id,
                        "lot_id": lot_id,
                        "product_id": lot["product_id"],
                        "mushroom_id": lot["mushroom_id"],
                        "batch_id": lot["batch_id"],
                        "harvest_id": "",
                        "movement_date": waste_date.isoformat(),
                        "movement_type": "WASTE_OUT",
                        "signed_quantity_kg": -waste_kg,
                        "unit_cost": lot["unit_cost"],
                        "total_movement_value": round(-waste_kg * lot["unit_cost"], 2),
                        "expiry_date": lot["expiry_date"].isoformat(),
                        "reason": reason,
                        "reference_transaction_id": waste_id,
                        "source_type": SOURCE_TYPE,
                        "created_at": ts(waste_date),
                    })

        console.print(f"   [green][OK][/green] Waste/spoilage events: {len(self.waste_events)}")

    def _inject_customer_returns(self) -> None:
        console.print("[bold]Step 7/7[/bold] Generating customer return records...")

        cfg = self.cfg
        eligible_lines = [ln for ln in self._completed_lines if ln["quantity_fulfilled_kg"] > 0.2]
        if not eligible_lines:
            return

        n_returns = min(cfg["inject_customer_returns"], len(eligible_lines))
        return_reasons = [
            "Mushrooms degraded in transit - heat exposure",
            "Quality below agreed specification - bacterial blotch",
            "Incorrect variety delivered",
            "Excess order - customer over-ordered",
            "Damaged packaging on arrival",
        ]

        sampled = self.rng.sample(eligible_lines, n_returns)

        for orig_line in sampled:
            return_kg = round(orig_line["quantity_fulfilled_kg"] * self.rng.uniform(0.2, 0.8), 3)
            return_date_str = orig_line["created_at"][:10]
            return_date = date.fromisoformat(return_date_str) + timedelta(days=self.rng.randint(1, 3))
            if return_date > self.end_date:
                return_date = self.end_date

            return_value = round(return_kg * orig_line["unit_selling_price"], 2)
            reason = self.rng.choice(return_reasons)

            ret_id = make_id("RET-", self._return_counter)
            self._return_counter += 1

            self.returns.append({
                "return_id": ret_id,
                "original_order_line_id": orig_line["order_line_id"],
                "original_order_id": orig_line["order_id"],
                "product_id": orig_line["product_id"],
                "mushroom_id": orig_line["mushroom_id"],
                "lot_id": orig_line["lot_id"],
                "return_date": return_date.isoformat(),
                "return_type": "CUSTOMER_RETURN",
                "return_kg": return_kg,
                "credit_value": return_value,
                "reason": reason,
                "disposition": "Discarded - perishable goods",
                "source_type": SOURCE_TYPE,
                "created_at": ts(return_date),
            })

            mov_id = make_id("MOV-", self._movement_counter)
            self._movement_counter += 1
            lot = self._lot_meta.get(orig_line["lot_id"])
            unit_cost = lot["unit_cost"] if lot else 0.0
            self.inventory_movements.append({
                "movement_id": mov_id,
                "lot_id": orig_line["lot_id"],
                "product_id": orig_line["product_id"],
                "mushroom_id": orig_line["mushroom_id"],
                "batch_id": lot["batch_id"] if lot else "",
                "harvest_id": "",
                "movement_date": return_date.isoformat(),
                "movement_type": "RETURN_DISCARDED",
                "signed_quantity_kg": 0.0,
                "unit_cost": unit_cost,
                "total_movement_value": 0.0,
                "expiry_date": lot["expiry_date"].isoformat() if lot else "",
                "reason": f"Customer return - {reason}. Discarded.",
                "reference_transaction_id": ret_id,
                "source_type": SOURCE_TYPE,
                "created_at": ts(return_date),
            })

        console.print(f"   [green][OK][/green] Customer returns: {len(self.returns)}")

    def _apply_data_quality_anomalies(self) -> None:
        cfg = self.cfg

        if self.purchases:
            for _ in range(cfg["inject_duplicate_invoices"]):
                orig = self.rng.choice(self.purchases).copy()
                orig["source_type"] = "synthetic_demo_DQ_TEST"
                orig["created_at"] = ts(
                    date.fromisoformat(orig["purchase_date"]) + timedelta(days=1)
                )
                self.purchases.append(orig)

        if self.harvest_records:
            bad = self.rng.choice(self.harvest_records).copy()
            bad["harvest_id"] = make_id("HRV-DQ-", self._harvest_counter)
            self._harvest_counter += 1
            bad["accepted_weight_kg"] = round(bad["gross_harvested_kg"] + 2.0, 3)
            bad["source_type"] = "synthetic_demo_DQ_TEST"
            self.harvest_records.append(bad)

        if self.sales_order_lines:
            bad2 = self.rng.choice(self.sales_order_lines).copy()
            bad2["order_line_id"] = make_id("LIN-DQ-", self._line_counter)
            self._line_counter += 1
            bad2["quantity_fulfilled_kg"] = round(bad2["quantity_ordered_kg"] + 5.0, 3)
            bad2["source_type"] = "synthetic_demo_DQ_TEST"
            self.sales_order_lines.append(bad2)

        if self.production_batches:
            bad3 = self.rng.choice(self.production_batches).copy()
            bad3["batch_id"] = make_id("BAT-DQ-", self._batch_counter)
            self._batch_counter += 1
            bad3["batch_start_date"] = ""
            bad3["source_type"] = "synthetic_demo_DQ_TEST"
            self.production_batches.append(bad3)

    def export_csv(self, output_dir: str | Path) -> None:
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)

        datasets = {
            "mushroom_varieties": self.mushroom_varieties,
            "locations": self.locations,
            "expense_categories": self.expense_categories,
            "products": self.products,
            "suppliers": self.suppliers,
            "customers": self.customers,
            "production_batches": self.production_batches,
            "harvest_records": self.harvest_records,
            "inventory_movements": self.inventory_movements,
            "sales_orders": self.sales_orders,
            "sales_order_lines": self.sales_order_lines,
            "expenses": self.expenses,
            "purchases": self.purchases,
            "waste_events": self.waste_events,
            "returns": self.returns,
        }

        manifest = {
            "generated_at": datetime.utcnow().isoformat() + "Z",
            "scale": self.scale,
            "seed": self.seed,
            "period_start": self.start_date.isoformat(),
            "period_end": self.end_date.isoformat(),
            "files": {},
        }

        for name, records in datasets.items():
            if not records:
                continue
            filepath = output_path / f"{name}.csv"
            df = pd.DataFrame(records)
            df.to_csv(filepath, index=False, quoting=csv.QUOTE_NONNUMERIC)
            manifest["files"][name] = {
                "filename": f"{name}.csv",
                "row_count": len(records),
                "columns": list(df.columns),
            }

        manifest_path = output_path / "generation_manifest.json"
        with open(manifest_path, "w", encoding="utf-8") as f:
            json.dump(manifest, f, indent=2)

        console.print(f"\n[bold green][OK] Export complete -> {output_path.resolve()}[/bold green]")
        self._print_file_table(manifest["files"])

    def _print_summary(self) -> None:
        console.print("\n[bold yellow]-- Dataset Summary --[/bold yellow]")
        summary = [
            ("Production Batches", len(self.production_batches)),
            ("Harvest Records",    len(self.harvest_records)),
            ("Inventory Movements",len(self.inventory_movements)),
            ("Sales Orders",       len(self.sales_orders)),
            ("Sales Order Lines",  len(self.sales_order_lines)),
            ("Expenses",           len(self.expenses)),
            ("Purchases",          len(self.purchases)),
            ("Waste Events",       len(self.waste_events)),
            ("Customer Returns",   len(self.returns)),
        ]
        t = Table(show_header=True, header_style="bold cyan")
        t.add_column("Dataset", style="white")
        t.add_column("Records", justify="right", style="yellow")
        for label, count in summary:
            t.add_row(label, str(count))
        console.print(t)

    def _print_file_table(self, files: dict) -> None:
        t = Table(show_header=True, header_style="bold cyan")
        t.add_column("File", style="white")
        t.add_column("Rows", justify="right", style="yellow")
        t.add_column("Columns", justify="right", style="dim")
        for name, meta in files.items():
            t.add_row(meta["filename"], str(meta["row_count"]), str(len(meta["columns"])))
        console.print(t)


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="MycoMetrics synthetic data generator for FungiFlow Organics."
    )
    parser.add_argument("--scale", choices=["small", "full"], default="small",
                        help="Dataset volume preset (default: small)")
    parser.add_argument("--seed", type=int, default=42,
                        help="Random seed for full reproducibility (default: 42)")
    parser.add_argument("--out", default="data/generated",
                        help="Output directory for CSV files (default: data/generated)")
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    generator = MycoDataGenerator(scale=args.scale, seed=args.seed)
    generator.generate()
    generator.export_csv(args.out)


if __name__ == "__main__":
    main()

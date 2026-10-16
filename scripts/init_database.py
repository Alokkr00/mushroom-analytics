"""
mycometrics/scripts/init_database.py
====================================
PostgreSQL database initialization script.

Executes DDL scripts in sequence:
1. sql/initialization/01_create_schemas.sql
2. sql/initialization/02_create_raw_tables.sql
3. sql/initialization/03_create_audit_tables.sql
4. sql/initialization/04_create_indexes_constraints.sql

Reads connection settings from .env file.
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

from dotenv import load_dotenv
import psycopg2
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from rich.console import Console
from rich.table import Table

console = Console(highlight=False, emoji=False)

# Load environment configuration
load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "mycometrics")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")

DDL_FILES = [
    "sql/initialization/01_create_schemas.sql",
    "sql/initialization/02_create_raw_tables.sql",
    "sql/initialization/03_create_audit_tables.sql",
    "sql/initialization/04_create_indexes_constraints.sql",
]


def ensure_database_exists() -> None:
    """Connect to default 'postgres' database to create target database if missing."""
    console.print(f"[bold cyan]Checking target database '{DB_NAME}' on {DB_HOST}:{DB_PORT}...[/bold cyan]")
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname="postgres",
            user=DB_USER,
            password=DB_PASSWORD,
            connect_timeout=5,
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()
        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s;", (DB_NAME,))
        exists = cur.fetchone()
        if not exists:
            console.print(f"Database '{DB_NAME}' not found. Creating...")
            cur.execute(sql.SQL("CREATE DATABASE {};").format(sql.Identifier(DB_NAME)))
            console.print(f"[bold green][OK] Database '{DB_NAME}' created.[/bold green]")
        else:
            console.print(f"[bold green][OK] Database '{DB_NAME}' exists.[/bold green]")
        cur.close()
        conn.close()
    except psycopg2.OperationalError as e:
        console.print(f"[bold red][ERROR] Unable to connect to PostgreSQL server on {DB_HOST}:{DB_PORT}.[/bold red]")
        console.print(f"Details: {e}")
        console.print("\n[yellow]Troubleshooting Steps:[/yellow]")
        console.print("1. Confirm PostgreSQL service is installed and running on port 5432.")
        console.print("2. Check credentials in .env file (DB_USER, DB_PASSWORD, DB_PORT).")
        console.print("3. To install PostgreSQL on Windows 11 via winget: winget install PostgreSQL.PostgreSQL.16")
        sys.exit(1)


def execute_ddl_scripts() -> None:
    """Connect to target database and execute all initialization DDL scripts."""
    console.print(f"\n[bold cyan]Connecting to '{DB_NAME}' to execute DDL scripts...[/bold cyan]")
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )
    cur = conn.cursor()

    for ddl_path_str in DDL_FILES:
        ddl_path = Path(ddl_path_str)
        if not ddl_path.exists():
            console.print(f"[bold red][FAIL] Missing DDL file: {ddl_path}[/bold red]")
            continue
        console.print(f"Executing: [yellow]{ddl_path_str}[/yellow]...")
        with open(ddl_path, "r", encoding="utf-8") as f:
            ddl_sql = f.read()
        cur.execute(ddl_sql)
        conn.commit()
        console.print(f"   [green][OK] Finished {ddl_path.name}[/green]")

    # Query information_schema to verify created tables
    cur.execute("""
        SELECT table_schema, table_name, table_type
        FROM information_schema.tables
        WHERE table_schema IN ('raw', 'staging', 'analytics', 'audit')
        ORDER BY table_schema, table_name;
    """)
    rows = cur.fetchall()

    t = Table(show_header=True, header_style="bold cyan")
    t.add_column("Schema", style="yellow")
    t.add_column("Table Name", style="white")
    t.add_column("Type", style="dim")
    for s, n, tp in rows:
        t.add_row(s, n, tp)

    console.print("\n[bold green]=== Database Initialization Complete ===[/bold green]")
    console.print(t)
    console.print(f"Total objects created across schemas: [yellow]{len(rows)}[/yellow]\n")

    cur.close()
    conn.close()


def main():
    ensure_database_exists()
    execute_ddl_scripts()


if __name__ == "__main__":
    main()

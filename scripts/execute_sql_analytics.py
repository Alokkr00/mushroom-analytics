"""
==============================================================================
MycoMetrics - SQL Analytics & Reconciliation Execution Engine
Purpose: Executes all Phase 6 analytical and financial reconciliation queries,
         records execution performance, prints tabular findings, and exports
         a comprehensive markdown analysis artifact.
==============================================================================
"""

import os
import sys
import time
import duckdb
import pandas as pd

# Enforce UTF-8 stdout encoding for Windows console
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

DB_PATH = 'data/warehouse.duckdb'
SQL_DIR = 'sql/analytics'
RECON_DIR = 'sql/reconciliation'
OUTPUT_DOC = 'docs/sql_analytics_findings.md'

def run_query_file(con, file_path):
    print(f"\n=======================================================")
    print(f"Executing: {os.path.basename(file_path)}")
    print(f"=======================================================")
    with open(file_path, 'r', encoding='utf-8') as f:
        full_sql = f.read()

    # Split on semicolons for multi-statement scripts
    raw_statements = full_sql.split(';')
    results = []
    
    for idx, stmt in enumerate(raw_statements):
        clean_stmt = stmt.strip()
        if not clean_stmt or clean_stmt.startswith('--') and '\n' not in clean_stmt:
            continue
        
        t0 = time.time()
        try:
            # Check if statement is a SELECT / WITH query returning rows
            first_keyword = clean_stmt.split()[0].upper() if clean_stmt.split() else ''
            while first_keyword.startswith('--') or first_keyword.startswith('/*'):
                # skip initial comment lines to find actual SQL command
                lines = [l.strip() for l in clean_stmt.splitlines() if l.strip() and not l.strip().startswith('--')]
                first_keyword = lines[0].split()[0].upper() if lines else ''
                break

            if first_keyword in ('SELECT', 'WITH'):
                df = con.execute(clean_stmt).df()
                elapsed_ms = (time.time() - t0) * 1000
                print(f"  [OK] Statement {idx+1}: {len(df)} rows returned ({elapsed_ms:.1f} ms)")
                print(df.head(10).to_string(index=False))
                results.append({
                    "file": os.path.basename(file_path),
                    "statement_idx": idx + 1,
                    "elapsed_ms": elapsed_ms,
                    "row_count": len(df),
                    "dataframe": df
                })
            else:
                con.execute(clean_stmt)
                elapsed_ms = (time.time() - t0) * 1000
                print(f"  [OK] Command {idx+1} executed ({elapsed_ms:.1f} ms)")
        except Exception as e:
            print(f"  [ERROR] Statement {idx+1} failed: {e}")
            raise e
            
    return results

def main():
    if not os.path.exists(DB_PATH):
        print(f"[ERROR] Database file {DB_PATH} not found.")
        sys.exit(1)

    con = duckdb.connect(DB_PATH)
    
    all_runs = []
    sql_files = sorted([os.path.join(SQL_DIR, f) for f in os.listdir(SQL_DIR) if f.endswith('.sql')])
    recon_files = sorted([os.path.join(RECON_DIR, f) for f in os.listdir(RECON_DIR) if f.endswith('.sql')])
    
    target_files = sql_files + recon_files
    print(f"Found {len(target_files)} SQL query files to execute.")

    for sf in target_files:
        runs = run_query_file(con, sf)
        all_runs.extend(runs)
        
    con.close()
    
    # Generate Markdown documentation
    os.makedirs(os.path.dirname(OUTPUT_DOC), exist_ok=True)
    with open(OUTPUT_DOC, 'w', encoding='utf-8') as out:
        out.write("# MycoMetrics - Phase 6: Advanced SQL Business Analytics & Reconciliation Findings\n\n")
        out.write("This document records the exact query results, biological findings, unit economics, and audit proofs executed against the transformed analytical warehouse.\n\n")
        
        for r in all_runs:
            out.write(f"## {r['file']} - Query Statement {r['statement_idx']}\n")
            out.write(f"- **Execution Time**: {r['elapsed_ms']:.1f} ms\n")
            out.write(f"- **Rows Returned**: {r['row_count']}\n\n")
            out.write("```\n")
            out.write(r['dataframe'].to_string(index=False))
            out.write("\n```\n\n")
            
    print(f"\n[OK] All {len(target_files)} analytical query suites passed successfully.")
    print(f"[OK] Documented results exported to: {OUTPUT_DOC}")

if __name__ == '__main__':
    main()

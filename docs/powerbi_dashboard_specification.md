# MycoMetrics - Power BI Dashboard Architecture & Design Specification

**Organization**: FungiFlow Organics  
**Author**: Data Analytics & BI Engineering Team  
**Technology**: Power BI Desktop | Data Source: DuckDB / Conformed Star Schema CSVs  
**Status**: Production Ready  

---

## 1. Executive Data Model Architecture

The Power BI analytical model is architected as a pure **Star Schema** with one central date dimension, six conformed entity dimensions, six grain fact tables, and five high-performance pre-aggregated reporting marts.

### 1.1 Model Relationships & Cardinality Table

| From (Fact / Child Table) | Foreign Key | To (Dimension / Parent Table) | Primary Key | Cardinality | Cross Filter | Active |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `fact_sales` | `order_date` | `dim_date` | `date_key` | Many to One (`*:1`) | Single | Yes |
| `fact_sales` | `customer_id` | `dim_customer` | `customer_id` | Many to One (`*:1`) | Single | Yes |
| `fact_sales` | `product_id` | `dim_product` | `product_id` | Many to One (`*:1`) | Single | Yes |
| `fact_sales` | `mushroom_id` | `dim_mushroom` | `mushroom_id` | Many to One (`*:1`) | Single | Yes |
| `fact_harvest` | `harvest_date` | `dim_date` | `date_key` | Many to One (`*:1`) | Single | Yes |
| `fact_harvest` | `batch_id` | `fact_production_batches` | `batch_id` | Many to One (`*:1`) | Single | Yes |
| `fact_production_batches`| `batch_start_date`| `dim_date` | `date_key` | Many to One (`*:1`) | Single | Yes |
| `fact_production_batches`| `mushroom_id` | `dim_mushroom` | `mushroom_id` | Many to One (`*:1`) | Single | Yes |
| `fact_production_batches`| `location_id` | `dim_location` | `location_id` | Many to One (`*:1`) | Single | Yes |
| `fact_inventory_movements`| `movement_date` | `dim_date` | `date_key` | Many to One (`*:1`) | Single | Yes |
| `fact_inventory_movements`| `product_id` | `dim_product` | `product_id` | Many to One (`*:1`) | Single | Yes |
| `fact_inventory_movements`| `mushroom_id` | `dim_mushroom` | `mushroom_id` | Many to One (`*:1`) | Single | Yes |
| `fact_expenses` | `expense_date` | `dim_date` | `date_key` | Many to One (`*:1`) | Single | Yes |
| `fact_expenses` | `category_id` | `dim_expense_category` | `category_id` | Many to One (`*:1`) | Single | Yes |
| `fact_procurement` | `purchase_date`| `dim_date` | `date_key` | Many to One (`*:1`) | Single | Yes |
| `fact_procurement` | `supplier_id` | `dim_supplier` | `supplier_id` | Many to One (`*:1`) | Single | Yes |

```
                ┌───────────────┐
                │   dim_date    │
                └───────┬───────┘
                        │ (1:*)
     ┌──────────────────┼───────────────────┐
     │                  │                   │
┌────┴────────┐   ┌─────┴──────┐     ┌──────┴──────┐
│ fact_sales  │   │fact_harvest│     │fact_expenses│
└────┬────────┘   └─────┬──────┘     └──────┬──────┘
     │ (*:1)            │ (*:1)             │ (*:1)
┌────┴────────┐   ┌─────┴──────────────────┐│
│dim_customer │   │fact_production_batches ││
└─────────────┘   └─────┬──────────────────┘│
                        │ (*:1)             │
                  ┌─────┴────────┐   ┌──────┴──────────────┐
                  │ dim_mushroom │   │dim_expense_category │
                  └──────────────┘   └─────────────────────┘
```

---

## 2. Interactive Dashboard Pages

The reporting suite consists of four specialized analytical dashboards providing complete operational visibility.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        MYCOMETRICS BI SUITE                            │
├────────────────────┬────────────────────┬──────────────────────────────┤
│ Page 1: Executive  │ Page 2: Biological │ Page 3: Sales & Customer     │
│ P&L & Cash Flow    │ Cultivation Yield  │ Pricing Profitability        │
├────────────────────┴────────────────────┴──────────────────────────────┤
│ Page 4: Inventory, Cold-Chain Spoilage & Shrinkage Operations          │
└────────────────────────────────────────────────────────────────────────┘
```

---

### Page 1: Executive Summary & Financial P&L

**Target Audience**: Farm Founder, Commercial Director, Investors  
**Objective**: Monitor financial solvency, gross margin sustainability, operating expense burn, and net cash trajectory.

#### Layout Wireframe
```
┌──────────────────────────────────────────────────────────────────────────┐
│ [Date Slicer]          [Variety Filter]           [Sales Channel Slicer] │
├───────────────┬────────────────┬────────────────┬────────────────────────┤
│ Net Revenue   │ Gross Margin % │ EBITDA Result  │ Total Harvest Yield    │
│ $7,913.10     │ 78.8%          │ -$4,524.68     │ 706.2 kg               │
├───────────────┴────────────────┴────────────────┴────────────────────────┤
│ Visual 1: Monthly Financial Performance (P&L Bar & Margin % Line)        │
│ [Bars: Net Revenue vs COGS vs Cash OPEX | Line: Operating Margin %]      │
├────────────────────────────────────────┬─────────────────────────────────┤
│ Visual 2: Revenue Waterfall Bridge     │ Visual 3: Operating Expense Mix │
│ Gross Invoiced ($9,754)                │ Donut Chart:                     │
│  - Discounts ($1,765)                  │  • Facility Rent: 48.2%         │
│  - Damage Credits ($76)                │  • Electricity: 24.1%           │
│  = Net Recognized ($7,913)             │  • Labor & Insurance: 27.7%     │
└────────────────────────────────────────┴─────────────────────────────────┘
```

#### Visual Component Specifications
1. **Header KPI Cards**:
   - `[Net Recognized Revenue]`: Format `$#,##0.00`
   - `[Gross Margin %]`: Format `0.0%` (Conditional formatting: Green $\ge 70\%$, Yellow $60-70\%$, Red $<60\%$)
   - `[Net Operating Result]`: Format `$#,##0.00` (Red if negative, Green if positive)
   - `[Accepted Harvest Yield kg]`: Format `#,##0.0 kg`
2. **Visual 1 (Clustered Column & Line Chart)**:
   - X-Axis: `dim_date[Year-Month]`
   - Column Values: `[Net Recognized Revenue]`, `[Total Cost of Goods Sold COGS]`, `[Total Operating Expenses OPEX]`
   - Line Values: `[Operating Margin %]`
3. **Visual 2 (Waterfall Chart)**:
   - Category: `Pipeline Breakdown` (Gross Revenue $\rightarrow$ Discounts $\rightarrow$ Return Credits $\rightarrow$ Net Recognized Revenue)
   - Value: Financial Amount ($)
4. **Visual 3 (Donut Chart)**:
   - Legend: `dim_expense_category[category_name]`
   - Values: `[Total Operating Expenses OPEX]`

---

### Page 2: Cultivation & Biological Performance

**Target Audience**: Head Grower, Farm Operations Lead  
**Objective**: Track biological efficiency against scientific strain benchmarks, identify flush decay drop-offs, and monitor room environmental performance.

#### Layout Wireframe
```
┌──────────────────────────────────────────────────────────────────────────┐
│ [Growing Room Slicer]      [Strain Slicer]          [Flush Number]       │
├───────────────┬────────────────┬────────────────┬────────────────────────┤
│ Batches Run   │ Accepted Yield │ Biological Eff │ Rejection Rate         │
│ 31 Batches    │ 706.2 kg       │ 58.6% Avg      │ 4.4%                   │
├───────────────┴────────────────┴────────────────┴────────────────────────┤
│ Visual 1: Biological Efficiency by Variety vs Target Benchmark (Gauges)  │
│ Pearl Oyster: 83.4% [Target 75%]  | Lion's Mane: 48.5% [Target 50%]     │
│ Shiitake:     35.7% [Target 35%]                                         │
├────────────────────────────────────────┬─────────────────────────────────┤
│ Visual 2: Flush Yield Decay Dynamics   │ Visual 3: Growing Room League   │
│ Area Chart: Flush 1 (61.4%) vs Flush 2 │ Room A vs Room B vs Room C:     │
│ (25.2%) vs Flush 3 (13.4%)             │ Inoculated, Yield, BE %, Cost/kg│
└────────────────────────────────────────┴─────────────────────────────────┘
```

#### Visual Component Specifications
1. **Visual 1 (Gauge / Bullet Visuals)**:
   - Value: `[Biological Efficiency %]`
   - Target Value: `[Target Biological Efficiency %]`
   - Minimum: 0%, Maximum: 100%
   - Callout: `[Biological Efficiency Gap %]`
2. **Visual 2 (Stacked Area Chart)**:
   - X-Axis: `fact_production_batches[batch_start_date]`
   - Y-Axis: `[Accepted Harvest Yield kg]`
   - Legend: `fact_harvest[flush_number]` (Flush 1, Flush 2, Flush 3)
3. **Visual 3 (Matrix Visual)**:
   - Rows: `dim_location[location_name]`
   - Columns: `dim_mushroom[mushroom_common_name]`
   - Values: `[Batches Inoculated]`, `[Accepted Harvest Yield kg]`, `[Biological Efficiency %]`, `[Rejection Rate %]`, `[Average Cycle Duration Days]`

---

### Page 3: Sales, Pricing & Customer Profitability

**Target Audience**: Sales Manager, Business Development Lead  
**Objective**: Maximize revenue realization across package formats, monitor account concentration (Pareto), and track wholesale channel margins.

#### Layout Wireframe
```
┌──────────────────────────────────────────────────────────────────────────┐
│ [Customer Segment]         [Route Zone]             [Package Format]     │
├───────────────┬────────────────┬────────────────┬────────────────────────┤
│ Total Shipped │ Realized ASP   │ Avg Order Val  │ Repeat Buyer Share     │
│ 393.3 kg      │ $20.12/kg      │ $70.65         │ 85.0%                  │
├───────────────┴────────────────┴────────────────┴────────────────────────┤
│ Visual 1: ASP Realization by Packaging SKU Format                        │
│ Clamshell Punnet: $33.40/kg | Kraft Bag: $26.10/kg | Bulk Crate: $19.20 │
├────────────────────────────────────────┬─────────────────────────────────┤
│ Visual 2: Customer Pareto Cumulative % │ Visual 3: Channel Margin Matrix │
│ Top 20% Accounts = 67.3% Revenue       │ Restaurant vs Grocer vs Market: │
│ [Ranked Bar + Cumulative Line %]       │ Volume, ASP/kg, COGS, Gross %   │
└────────────────────────────────────────┴─────────────────────────────────┘
```

#### Visual Component Specifications
1. **Visual 1 (Horizontal Bar Chart)**:
   - Y-Axis: `dim_product[package_format]`
   - X-Axis: `[Realized ASP per kg]`
   - Data Labels: Realized selling price formatted as `$#,##0.00/kg`
2. **Visual 2 (Line and Clustered Column Chart - Pareto)**:
   - Shared Axis: `dim_customer[customer_name]` (Sorted by Net Revenue Descending)
   - Column Values: `[Net Recognized Revenue]`
   - Line Values: `[Cumulative Revenue %]` (Reference line at 80%)
3. **Visual 3 (Table Visual)**:
   - Columns: `dim_customer[customer_segment]`, `[Total Fulfilled Quantity kg]`, `[Realized ASP per kg]`, `[Total Cost of Goods Sold COGS]`, `[Gross Profit]`, `[Gross Margin %]`

---

### Page 4: Inventory, Spoilage & Cold-Chain Operations

**Target Audience**: Inventory Coordinator, Quality Assurance Lead  
**Objective**: Eliminate supply chain waste, identify spoilage drivers, and track lot expiration risk.

#### Layout Wireframe
```
┌──────────────────────────────────────────────────────────────────────────┐
│ [Loss Stage Slicer]        [Spoilage Reason]        [Lot Risk Filter]    │
├───────────────┬────────────────┬────────────────┬────────────────────────┤
│ Lost Biomass  │ Sunk Loss $    │ Cold Spoilage  │ Critical Expiry Stock  │
│ 166.3 kg      │ $1,185.56      │ 129.9 kg (78%) │ 24.4 kg                │
├───────────────┴────────────────┴────────────────┴────────────────────────┤
│ Visual 1: Supply Chain Loss Funnel (Harvest Floor -> Cold Room -> Return)│
├────────────────────────────────────────┬─────────────────────────────────┤
│ Visual 2: Spoilage Root Causes         │ Visual 3: Lot Inventory Aging   │
│ Shelf Life Exceeded: 78.1%             │ Lot ID | Product | Expiry |     │
│ Bacterial Blotch:    19.8%             │ Available kg | Days Left | Risk │
│ Transit Damage:       2.1%             │ [Conditional Color Status]      │
└────────────────────────────────────────┴─────────────────────────────────┘
```

#### Visual Component Specifications
1. **Visual 1 (Funnel / Decomposition Tree Visual)**:
   - Category: `mart_inventory_waste[loss_stage]`
   - Values: `[Total Lost Quantity kg]`, `[Total Financial Loss $]`
2. **Visual 2 (Clustered Bar Chart)**:
   - Y-Axis: `mart_inventory_waste[reason_code]`
   - X-Axis: `[Total Lost Quantity kg]`
   - Color: By Mushroom Variety
3. **Visual 3 (Table Visual with Conditional Icons)**:
   - Columns: `lot_id`, `product_name`, `mushroom_common_name`, `expiry_date`, `current_available_stock_kg`, `days_until_expiration`, `inventory_risk_status`
   - Conditional Formatting:
     - `CRITICAL` (0–3 days remaining): Red background
     - `MODERATE` (4–7 days remaining): Yellow background
     - `HEALTHY` (>7 days remaining): Green background

---

## 3. Power BI Color Palette

| Token | Name | Hex Code | Purpose |
| :--- | :--- | :--- | :--- |
| **Primary** | Deep Fungi Blue | `#2B5B84` | Primary brand headers, volume bars, accepted yields |
| **Accent** | Spore Ochre | `#D95F02` | Electricity trendlines, retail punnet callouts |
| **Success** | Sprout Green | `#2CA02C` | Target achieved, healthy stock, gross margins $\ge 70\%$ |
| **Warning** | Amber Harvest | `#E67E22` | Flush 2 yields, moderate expiration stock (4–7 days) |
| **Danger** | Spoilage Crimson | `#C0392B` | Crop rejections, cold room spoilage, net monthly deficit |
| **Neutral** | Slate Gray | `#4A5568` | Secondary labels, benchmark target lines |
| **Background**| Crisp Canvas | `#F8FAFC` | Page canvas background |

---

## 4. Step-by-Step Desktop Build Instructions

1. **Launch Power BI Desktop**.
2. **Import Conformed Tables**:
   - Click **Get Data** $\rightarrow$ **Text/CSV** (or **Folder** pointing to `D:\Mushroom Analytics\powerbi\data`).
   - Load all 18 CSV files.
3. **Verify Relationships**:
   - Open **Model View**.
   - Confirm active `*:1` relationships match the table in Section 1.1.
4. **Create Measure Table**:
   - Click **Enter Data** $\rightarrow$ Name table `_Measures`.
   - Copy and paste the DAX definitions from [`powerbi/dax_measures.dax`](file:///d:/Mushroom%20Analytics/powerbi/dax_measures.dax).
   - Assign measures to their designated Display Folders (`01_Sales_and_Revenue`, etc.).
5. **Configure Canvases**:
   - Set Page size to **16:9** (1280 x 720).
   - Apply canvas background color `#F8FAFC`.
   - Build out the 4 dashboard pages using the wireframe specifications above.

---

## 5. Summary Deliverables

- Production DAX Library: [`powerbi/dax_measures.dax`](file:///d:/Mushroom%20Analytics/powerbi/dax_measures.dax) (30+ production measures).
- Power BI Staged Data: [`powerbi/data/`](file:///d:/Mushroom%20Analytics/powerbi/data) (18 conformed tables).
- Power BI Tables Manifest: [`powerbi/data/tables_manifest.json`](file:///d:/Mushroom%20Analytics/powerbi/data/tables_manifest.json).
- Comprehensive Architecture Spec: [`docs/powerbi_dashboard_specification.md`](file:///d:/Mushroom%20Analytics/docs/powerbi_dashboard_specification.md).

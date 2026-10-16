# KPI & Metric Glossary: MycoMetrics Business Intelligence

This glossary provides standardized business definitions, calculation logic, units, aggregation levels, and limitations for all metrics used across SQL models, dbt marts, and Power BI dashboards.

---

## 1. Production KPIs

### Total Harvested Weight
- **Business Definition**: Total physical weight of all mushrooms cut from fruiting blocks prior to sorting.
- **Formula**:
  $$\sum \text{gross\_harvested\_kg}$$
- **Grain**: Harvest event / Flush.
- **Unit**: Kilograms (kg).
- **Source**: `fact_harvest`.
- **Validation**: $\text{gross\_harvested\_kg} = \text{accepted\_weight\_kg} + \text{rejected\_weight\_kg}$.

### Accepted Yield
- **Business Definition**: Total marketable weight meeting quality standards for sale or packaging.
- **Formula**:
  $$\sum \text{accepted\_weight\_kg}$$
- **Grain**: Harvest event / Flush.
- **Unit**: Kilograms (kg).
- **Source**: `fact_harvest`.

### Harvest Rejection Rate (%)
- **Business Definition**: Percentage of harvested fruitbody weight discarded at sorting due to blemishes, blotch, or physical defects.
- **Formula**:
  $$\frac{\sum \text{rejected\_weight\_kg}}{\sum \text{gross\_harvested\_kg}} \times 100$$
- **Grain**: Aggregated (Batch, Variety, Period).
- **Unit**: Percentage (%).
- **Known Limitations**: Does not include completely contaminated blocks discarded before fruiting.

### Biological Efficiency (BE %)
- **Business Definition**: Standard mycological productivity index measuring fresh mushroom yield relative to dry substrate mass.
- **Formula**:
  $$\frac{\sum \text{Total Accepted Harvest (kg)}}{\text{Dry Substrate Input (kg)}} \times 100$$
- **Grain**: Batch grain.
- **Unit**: Percentage (%).
- **Rule**: Must NEVER use wet hydrated substrate in the denominator (wet substrate includes ~60% water, which distorts BE).

### Batch Target Achievement (%)
- **Business Definition**: Actual accepted harvest compared to planned production target.
- **Formula**:
  $$\frac{\text{Total Batch Accepted Harvest (kg)}}{\text{Target Yield (kg)}} \times 100$$
- **Grain**: Batch.
- **Unit**: Percentage (%).

### Production Cycle Duration
- **Business Definition**: Total calendar days elapsed from initial inoculation to completion of the final harvest flush.
- **Formula**:
  $$\text{MAX}(\text{harvest\_date}) - \text{batch\_start\_date}$$
- **Grain**: Batch.
- **Unit**: Days.

### Direct Cultivation Cost per Kg
- **Business Definition**: Direct batch costs (substrate + spawn + bags + attributable batch labor) divided by accepted kilograms produced.
- **Formula**:
  $$\frac{\text{Attributable Batch Direct Cost (\$)}}{\text{Total Batch Accepted Harvest (kg)}}$$
- **Grain**: Batch.
- **Unit**: \$ / kg.
- **Known Limitations**: Excludes general farm overhead (rent, electricity) unless an explicit allocation driver is applied.

---

## 2. Commercial Sales KPIs

### Gross Sales
- **Business Definition**: Total undiscounted revenue based on fulfilled quantities and list prices.
- **Formula**:
  $$\sum (\text{quantity\_fulfilled\_kg} \times \text{unit\_selling\_price})$$
- **Grain**: Order Line.
- **Unit**: Currency (\$).

### Net Sales
- **Business Definition**: Realized commercial revenue after deducting volume discounts, promotional allowances, and accepted delivery returns.
- **Formula**:
  $$\text{Gross Sales} - \sum \text{discount\_amount} - \sum \text{returned\_sales\_amount}$$
- **Grain**: Order Line / Time period.
- **Unit**: Currency (\$).

### Average Selling Price (ASP) per Kg
- **Business Definition**: Weighted average net realized price per kilogram of fresh produce sold.
- **Formula**:
  $$\frac{\text{Net Sales (\Phi)}}{\sum \text{quantity\_fulfilled\_kg}}$$
- **Grain**: Variety / Channel / Customer Segment.
- **Unit**: \$ / kg.

### Order Fulfillment Rate (%)
- **Business Definition**: Proportion of customer-demanded volume successfully fulfilled and dispatched.
- **Formula**:
  $$\frac{\sum \text{quantity\_fulfilled\_kg}}{\sum \text{quantity\_ordered\_kg}} \times 100$$
- **Grain**: Order / Aggregate.
- **Unit**: Percentage (%).
- **Significance**: Identifies missed commercial opportunities due to stockouts or harvest timing mismatches.

### Average Order Value (AOV)
- **Business Definition**: Average net sales revenue per completed delivery order.
- **Formula**:
  $$\frac{\text{Total Net Sales}}{\text{Count of Distinct Completed Orders}}$$
- **Grain**: Period / Segment.
- **Unit**: Currency (\$).

---

## 3. Cost & Profitability KPIs

### Cost of Goods Sold (COGS)
- **Business Definition**: Direct material and packaging cost associated specifically with the kilograms sold during the period.
- **Formula**:
  $$\sum (\text{quantity\_fulfilled\_kg} \times \text{unit\_product\_cost})$$
- **Grain**: Order Line / Period.
- **Unit**: Currency (\$).

### Gross Profit & Gross Margin (%)
- **Business Definition**: Revenue retained after covering direct product costs.
- **Formula**:
  $$\text{Gross Profit} = \text{Net Sales} - \text{COGS}$$
  $$\text{Gross Margin \%} = \frac{\text{Gross Profit}}{\text{Net Sales}} \times 100$$
- **Grain**: Product / Variety / Period.
- **Unit**: Currency (\$) and Percentage (%).

### Operating Expenses (OpEx)
- **Business Definition**: All non-capitalized operating overhead incurred in running the business (rent, utilities, fuel, marketing, insurance, general supplies).
- **Formula**:
  $$\sum \text{amount where expense\_behavior in ('Fixed Overhead', 'Variable Operating')}$$
- **Grain**: Financial Period (Month).
- **Unit**: Currency (\$).

### Operating Result (EBITDA Proxy)
- **Business Definition**: Operational surplus or deficit before interest, taxes, depreciation, and owner drawings.
- **Formula**:
  $$\text{Gross Profit} - \text{Operating Expenses}$$
- **Grain**: Month.
- **Unit**: Currency (\$).
- **Disclosure Rule**: Must be labeled as "Operating Result" rather than "Net Profit" when income tax, equipment depreciation, and owner sweat equity are unrecorded.

---

## 4. Inventory, Shelf-Life & Waste KPIs

### Closing Inventory
- **Business Definition**: Reconciled physical stock available on hand in cold storage at the close of a period.
- **Formula**:
  $$\text{Opening Stock} + \sum \text{Harvest Receipts} - \sum \text{Fulfilled Sales} - \sum \text{Waste / Spoilage Write-offs}$$
- **Grain**: Product / Day.
- **Unit**: Kilograms (kg).

### Stock at Expiry Risk
- **Business Definition**: Available unallocated inventory whose remaining shelf-life is $\le 48 \text{ hours}$ (e.g., lot age $\ge 4 \text{ days}$).
- **Formula**:
  $$\sum \text{available\_stock\_kg where } (\text{expiry\_date} - \text{current\_date}) \le 2 \text{ days}$$
- **Grain**: Current Snapshot.
- **Unit**: Kilograms (kg) and Currency Value (\$).

### Spoilage Rate (%)
- **Business Definition**: Volume of harvested produce lost to cold-storage decay or shelf-life expiry relative to total accepted harvest.
- **Formula**:
  $$\frac{\sum \text{spoilage\_waste\_kg}}{\sum \text{accepted\_harvest\_kg}} \times 100$$
- **Grain**: Month / Variety.
- **Unit**: Percentage (%).

### Total Waste Financial Impact
- **Business Definition**: Cumulative economic loss from rejected harvest floor produce plus cold storage spoilage.
- **Formula**:
  $$\sum (\text{rejected\_kg} \times \text{direct\_cultivation\_cost\_per\_kg}) + \sum (\text{spoiled\_kg} \times \text{unit\_valuation})$$
- **Grain**: Month / Variety.
- **Unit**: Currency (\$).

---

## 5. Customer & Commercial Concentration KPIs

### Customer Concentration Ratio (Top 3 & Top 5)
- **Business Definition**: Share of total net sales generated by the business's largest customers.
- **Formula**:
  $$\frac{\sum \text{Net Sales of Top } N \text{ Customers}}{\text{Total Business Net Sales}} \times 100$$
- **Grain**: Period.
- **Unit**: Percentage (%).
- **Risk Threshold**: If Top 3 accounts generate $> 60\%$ of revenue, concentration risk is flagged as **High**.

### Repeat Purchase Rate (%)
- **Business Definition**: Percentage of customers with two or more completed orders within an eligible window.
- **Formula**:
  $$\frac{\text{Count of Customers with } \ge 2 \text{ Orders}}{\text{Total Distinct Customers with } \ge 1 \text{ Order}} \times 100$$
- **Grain**: Customer cohort / Period.
- **Unit**: Percentage (%).

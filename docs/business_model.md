# Business Context & Operational Model: FungiFlow Organics (MycoMetrics)

## 1. Company Profile: FungiFlow Organics

**FungiFlow Organics** is an early-stage urban indoor mushroom cultivation and commercial distribution startup operating out of a leased 1,200 sq. ft. retrofitted warehouse with two insulated growing rooms (Grow Room A and Grow Room B), an incubation/colonization darkroom, a substrate preparation/sterilization area, and a walk-in cold-storage unit (2°C - 4°C).

The venture was founded by a solo entrepreneur-grower to supply premium gourmet and culinary mushrooms to local farm-to-table restaurants, specialty greengrocers, weekend community farmers' markets, and direct-to-consumer (D2C) home cooks.

### Current Operating Constraints & Realities:
- **Team Size**: 1 founder-operator + 1 part-time cultivation assistant.
- **Growing Infrastructure**: Two 400 sq. ft. climate-controlled fruiting rooms with manual misting/humidifiers and basic digital thermohygrometers; no automated IoT-controlled building management system.
- **Recording Mechanism**: Clipboards inside growing rooms, manual Google Sheets/Excel workbooks for sales orders and daily harvest logs, physical receipt shoeboxes, and bank account statements.
- **Working Capital**: Highly constrained; cash flow depends on rapid inventory turnaround due to the highly perishable nature of harvested fresh mushrooms (shelf life of 5 to 7 days).
- **Target Capacity**: 100 to 200 kg of fresh mushrooms per week across all varieties.

---

## 2. Cultivated Mushroom Varieties & Commercial Formats

To maintain operational sanity during startup phase, production is staged across three distinct biological species with varying growth speeds, biological efficiencies, substrate costs, and shelf-life profiles:

| Variety Name | Scientific Name | Growth Cycle (Days to 1st Harvest) | Typical Biological Efficiency (BE) | Substrate Formula | Primary Target Channel | Shelf Life |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Pearl / Blue Oyster** (*Pleurotus ostreatus*) | *Pleurotus ostreatus* | 21 - 25 days | 75% - 110% | Pasteurized chopped wheat straw + 10% wheat bran / cotton waste | Farmers' markets, Local diners, D2C | 5 - 6 days |
| **Lion's Mane** (*Hericium erinaceus*) | *Hericium erinaceus* | 28 - 35 days | 60% - 85% | Supplemented Hardwood Sawdust (Master's Mix: 50% sawdust, 50% soybean hulls) | High-end restaurants, boutique grocers | 6 - 8 days |
| **Shiitake** (*Lentinula edodes*) | *Lentinula edodes* | 55 - 75 days | 50% - 75% | Sterilized Oak/Hardwood Sawdust + wheat bran | Fine dining, dried direct sales, culinary retail | 8 - 12 days |

*Operational Note*: The startup started in Month 1 with Oyster mushrooms only (lowest barrier to entry, fastest turnaround). In Month 2, Lion's Mane was introduced to capture higher retail price points. In Month 3-4, Shiitake blocks were initiated due to longer colonization lead times.

### Finished Goods Product SKUs:
1. **Bulk Grade-A (kg)**: Sold to restaurants in 1 kg, 2 kg, and 5 kg food-grade reusable crates.
2. **Retail Clamshell Packs (200g / 250g)**: Breathable vented punnets with paper labels for specialty grocery stores.
3. **Retail Kraft Paper Bags (150g)**: Sold at weekend pop-up farmers' markets.
4. **Seconds / Kitchen Grade (kg)**: Slightly broken caps or stems sold at a 30-40% discount to local soup and ramen kitchens.

---

## 3. End-to-End Operational Lifecycle

The business operates a batch-driven cycle:

```
[Raw Material Procurement] 
        ↓
[Substrate Prep & Sterilization/Pasteurization] 
        ↓
[Inoculation with Grain Spawn] 
        ↓
[Incubation / Colonization (Dark Period)] 
        ↓
[Fruiting Room Transfer & Induction (Humidity, Light, FAE)] 
        ↓
[Harvesting (Flush 1 & Flush 2)] 
        ↓
[Quality Grading & Sorting (Accepted vs. Rejected Weight)] 
        ↓
[Packaging & Cold Storage Quarantine] 
        ↓
[Sales Order Receipt & Allocation] 
        ↓
[Dispatch & Delivery] 
        ↓
[Invoicing, Payment Collection & Spoilage Write-Off]
```

### Operational Batch vs. Flush Mechanics:
- A **Production Batch** represents a homogenous group of substrate blocks/bags inoculated on the same date with the same spawn lot and substrate formulation.
- Each batch produces multiple waves of fruitbodies, termed **Flushes**.
  - **Flush 1**: Typically produces 60-70% of total expected batch yield with highest quality.
  - **Flush 2**: Produces 20-30% of yield, 7 to 12 days after Flush 1.
  - **Flush 3**: Rarely economical in commercial indoor farming due to space opportunity cost and contamination risk; blocks are typically composted after Flush 2.

---

## 4. Financial & Unit Economics Structure

Fresh mushroom cultivation has distinct cost drivers:

### 1. Direct Costs (Cost of Goods Cultivated - COGC):
- **Raw Substrate Inputs**: Straw, hardwood pellets, soy hulls, gypsum.
- **Grain Spawn**: Sourced from commercial mycology labs (cost per 2 kg spawn bag).
- **Consumable Bags & Filters**: Autoclavable polypropylene filter-patch bags.
- **Direct Labor**: Inoculation, bag handling, and harvesting hours.

### 2. Variable Operational Costs:
- **Packaging**: Clamshell containers, kraft bags, printed thermal labels.
- **Sanitization & Hygiene**: Isopropyl alcohol, bleach, latex gloves, paper towels.
- **Delivery Fuel & Transport**: Local courier and personal vehicle mileage for wholesale drops.

### 3. Fixed Overhead:
- **Rent**: Facility lease for 1,200 sq. ft.
- **Electricity**: Substantial and continuous (cooling chillers, heating, ultrasonic humidifiers, inline exhaust fans).
- **Water**: Substrate hydration, room cleaning, and misting.
- **Tool Amortization & Maintenance**: Autoclave, impulse sealers, commercial scales.

---

## 5. Explicit Baseline Assumptions

1. **Currency**: USD ($) or standard base currency unit with 2-decimal precision (`NUMERIC(12,2)`).
2. **Measurement Standard**: All production and bulk weights tracked in **Kilograms (kg)** to 3 decimal places (`NUMERIC(10,3)`). All retail packaging converted cleanly to kg equivalent.
3. **Yield Definition**: 
   $$\text{Biological Efficiency (BE)} = \frac{\text{Fresh Harvested Weight (kg)}}{\text{Dry Substrate Weight (kg)}} \times 100$$
4. **Perishability Rule**: Fresh mushrooms must be sold within **5 calendar days** of harvest; stock reaching Day 6 in cold storage without an allocated order enters "Expiry Risk" and is discounted or written off on Day 7 as spoilage.
5. **No Phantom Profitability**: Any overhead or labor cost not reliably captured at the batch level will be clearly categorized as general operational expense rather than arbitrarily imputed into batch margins.

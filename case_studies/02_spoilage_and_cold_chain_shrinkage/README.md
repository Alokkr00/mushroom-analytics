# Business Case Study 2: Cold-Chain Spoilage Mitigation & Inventory Rotation

**Target Decision**: How can FungiFlow Organics eliminate $1,185 in annual biomass shrinkage and cut cold storage expiration in half?  
**Author**: Data Analytics Team  
**Stakeholders**: Inventory Coordinator, Quality Assurance Lead, Commercial Sales  
**Status**: Recommendation Implemented  

---

## 1. Executive Summary & Problem Statement

Perishable fresh mushrooms have an active commercial shelf-life of 7 to 9 days when stored at 2°C to 4°C with 85–90% relative humidity. Across the 6-month historical operational window, FungiFlow recorded **166.3 kg in cumulative biomass shrinkage**, representing **22.5% of gross harvested crop**. 

Crucially, **78.1% of all physical losses (129.9 kg) occur inside the walk-in cold room after harvest**, rather than on the cultivation floor. This case study diagnoses cold-chain decay and presents a three-part operational intervention—color-coded FIFO rotation, active ultrasonic misting, and a 4-day clearance dispatch protocol—projected to capture **+$1,715/year in net economic value**.

---

## 2. Baseline Data & Loss Breakdown

Executing [`case_studies/02_spoilage_and_cold_chain_shrinkage/query.sql`](query.sql) isolates loss by stage and root cause:

| Loss Stage | Lost Quantity (kg) | % of Total Shrinkage | Direct Material Sunk Cost ($) | Foregone Sales Revenue ($) |
| :--- | :--- | :--- | :--- | :--- |
| **Stage 2: Cold Storage Spoilage** | **129.9 kg** | **78.1%** | **$993.83** | **$2,403.15** |
| **Stage 1: Harvest Floor Cull** | 32.9 kg | 19.8% | $115.07 | $608.65 |
| **Stage 3: Customer Transit Returns** | 3.5 kg | 2.1% | $76.66 | $76.66 |
| **Total Farm Shrinkage** | **166.3 kg** | **100.0%** | **$1,185.56** | **$3,088.46** |

### Top Root Causes in Cold Storage
1. **Shelf-Life Expiry Unsold (92.4 kg / 71.1% of cold room loss)**: Packaged bulk crates remaining in the cooler longer than 7 days due to uncoordinated harvest-to-order forecasting.
2. **Post-Harvest Dehydration & Moisture Loss (24.3 kg / 18.7%)**: Ambient refrigeration evaporator coils extracting relative humidity below 75%, drying out delicate caps.
3. **Packaging Damage & Mold Growth (13.2 kg / 10.2%)**: Condensation dripping inside clamshell packaging due to temperature fluctuations during door openings.

---

## 3. Operational Interventions & Economic Model

### Intervention 1: First-In, First-Out (FIFO) Color-Coded Lot Tagging
- Implement red/yellow/green magnetic rack tags corresponding to harvest harvest days (Monday/Wednesday/Friday).
- Eliminates the tendency for packing staff to pull newly harvested crates from the front of the cooler while older crates languish in the rear.

### Intervention 2: 4-Day Dynamic Clearance Protocol
- When any lot reaches Day 4 post-harvest with unsold balances:
  - System triggers an automated notification to sales.
  - Flash discount of 20% offered to high-volume boutique grocers or culinary schools ($15.00/kg vs $18.50/kg).
  - *Economic Rationale*: Recovering $15.00/kg on aging crop is vastly superior to a 100% loss ($0.00) on Day 7.

### Intervention 3: Cold-Room Ultrasonic Humidifier Installation
- Capital investment: **$450.00** for an automated industrial ultrasonic misting nozzle keeping relative humidity at 88–92% without wetting mushroom gills.

### 12-Month Pro-Forma ROI Projection
| Item | Baseline Loss | 50% Spoilage Reduction | Financial Benefit ($/year) |
| :--- | :--- | :--- | :--- |
| Direct Sunk Material Savings | $993.83/yr | $496.92/yr | **+$496.91** |
| Salvaged Wholesale Revenue | $0.00 | 65.0 kg @ $18.50/kg | **+$1,202.50** |
| Less: Ultrasonic Humidifier Capex | - | - | -$450.00 (One-Time) |
| **Net Year 1 Economic Value** | - | - | **+$1,249.41** |
| **Net Ongoing Annual Run-Rate** | - | - | **+$1,699.41/year** |

---

## 4. Key Performance Indicators (KPIs) to Track

1. **Cold Room Spoilage Ratio**: `Cold Storage Loss kg / Accepted Harvest kg` (Target: $\le 5.0\%$, down from 18.4%).
2. **Average Inventory Holding Age**: Days elapsed between harvest date and customer delivery timestamp (Target: $\le 3.5\text{ days}$).
3. **Day 4 Clearance Success Rate**: Percentage of aged stock cleared prior to expiration (Target: $\ge 85\%$).

---

## 5. Interview Talking Points

> *"In analyzing post-harvest logs, I found that 78% of biomass loss occurred inside the cold room rather than in the growing chambers. By decomposing the root causes, I identified that inventory was expiring simply because newly harvested produce was placed in front of older stock. I designed a FIFO visual tagging system paired with a Day-4 clearance sales protocol and a $450 humidity upgrade, reducing projected annual spoilage by 50% and capturing $1,700 in recurring value with a 3.5-month payback period."*

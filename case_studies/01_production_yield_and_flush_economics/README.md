# Business Case Study 1: Production Yield Optimization & Flush 3 Rationalization

**Target Decision**: Should FungiFlow Organics terminate mushroom fruiting blocks after Flush 2 or continue through Flush 3?  
**Author**: Data Analytics Team  
**Stakeholders**: Head Grower, Operations Director, Founder  
**Status**: Recommendation Approved for Pilot  

---

## 1. Executive Summary & Problem Statement

FungiFlow Organics currently maintains fruiting blocks in climate-controlled growing rooms through three harvest flushes, spanning an average of 72 to 84 days per batch cycle. While conventional wisdom suggests harvesting "every possible gram" from inoculated blocks, operational data reveals that **Flush 3 yields collapse by 78% compared to Flush 1**, generating only **13.4% of total farm biomass** while consuming over **30% of growing room space, labor, and refrigeration electricity**. 

This investigation models the marginal economic contribution of Flush 3 and demonstrates that **terminating blocks after Flush 2 expands facility capacity by +28.8%**, accelerating room turns and generating an estimated **+$4,200/year in net operating profit**.

---

## 2. Baseline Data & Empirical Findings

Querying [`case_studies/01_production_yield_and_flush_economics/query.sql`](query.sql) against the conformed warehouse yields the empirical flush profile:

| Metric | Flush 1 (Peak) | Flush 2 (Secondary) | Flush 3 (Terminal) | Total / Variance |
| :--- | :--- | :--- | :--- | :--- |
| **Harvest Sessions** | 20 sessions | 16 sessions | 9 sessions | 45 sessions |
| **Accepted Yield (kg)** | 433.8 kg | 178.1 kg | 94.3 kg | 706.2 kg |
| **Yield Share (%)** | **61.4%** | **25.2%** | **13.4%** | 100.0% |
| **Mean Accepted Yield / Session**| **14.8 kg** | **6.1 kg** | **3.2 kg** | -78.4% drop vs F1 |
| **Average Rejection Rate (%)** | 2.1% | 4.8% | **9.4%** | 4.5x higher defect rate |
| **Gross Revenue Generated ($)** | $8,025.30 | $3,294.85 | $1,744.55 | Wholesale at $18.50/kg |
| **Harvest Labor Cost ($)** | $648.00 | $396.00 | $288.00 | Labor at $18/hr |
| **Room Climate Electricity ($)** | $1,080.00 | $864.00 | $486.00 | $4.50/room-day |
| **Net Marginal Flush Profit ($)** | **+$6,297.30** | **+$2,034.85** | **+$970.55** | Marginal Contribution |

---

## 3. Root Cause Analysis

1. **Substrate Nutrient Depletion**: Mushroom mycelium consumes readily available non-structural carbohydrates in Flush 1 and 2. By Flush 3, nutrient exhaustion forces slower growth, leading to smaller, lighter caps and lower Biological Efficiency.
2. **Elevated Biological Vulnerability**: Weakened third-flush blocks exhibit diminished immune resistance, resulting in a **9.4% cull rate** primarily caused by *Pseudomonas tolaasii* (bacterial blotch) and green mold (*Trichoderma*).
3. **Opportunity Cost of Room Capacity**: Each day a depleted block sits in the room producing 0.25 kg/day, it prevents a fresh, high-yielding Flush 1 block (producing 1.5 kg/day) from entering the chamber.

---

## 4. Strategic Alternatives & Scenario Modeling

- **Alternative A: Status Quo (Run 3 Flushes)**: Annual farm capacity capped at ~1,400 kg/year across 4.8 room turns per year.
- **Alternative B: Terminate at Flush 2 (2-Flush High Velocity Model)**:
  - Cycle duration reduced from 78 days to **56 days** (-28.2% duration).
  - Annual room turns increase from 4.8 to **6.5 turns per room/year (+35.4% velocity)**.
  - While harvest per block drops by 13.4%, annual facility biomass throughput increases from 1,400 kg to **1,720 kg (+22.8% net annual volume expansion)**.

### Financial Impact Model
$$\Delta \text{Revenue} = 320 \text{ additional kg} \times \$18.50/\text{kg} = +\$5,920.00$$
$$\Delta \text{Substrate Materials} = +\$1,720.00$$
$$\textbf{Net Annual Operating Upside} = +\$4,200.00/\text{year}$$

---

## 5. Recommended Action Plan

1. **Immediate SOP Revision (Week 1–2)**: Standardize block retirement immediately after Flush 2 is harvested. Spent blocks will be composted immediately.
2. **Inoculation Schedule Calibration (Week 3–4)**: Increase weekly inoculation cadence from 60 blocks to 80 blocks to feed the faster chamber cycle.
3. **Compost Monetization (Week 5–8)**: Partner with local organic community gardens to sell spent mushroom substrate (SMS) at $3.00/bag as premium organic soil conditioner, unlocking an estimated $600/year in secondary revenue.

---

## 6. Interview Script & Portfolio Talking Points

> *"When analyzing FungiFlow's cultivation logs, I noticed that while Flush 3 contributed 13.4% of total kilograms, it took up nearly a third of the growing room's calendar schedule. By running a marginal cost vs. revenue analysis, I demonstrated that Flush 3 yields barely broke even after accounting for harvesting labor and chiller electricity. I recommended transitioning to a 2-flush production model, which increases chamber velocity by 35% and projects an additional $4,200 in annual net operating profit on the exact same physical footprint."*

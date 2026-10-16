# Business Case Study 4: True Cost per kg & Operational Break-Even Analysis

**Target Decision**: What is FungiFlow's true fully-absorbed cost per kilogram, and what monthly production volume is required to achieve sustainable profitability?  
**Author**: Data Analytics Team  
**Stakeholders**: Founder, Financial Controller, Operations Lead  
**Status**: Foundational Financial Model Established  

---

## 1. Executive Summary & Problem Statement

During its initial five months of operation (May–September 2024), FungiFlow's founder faced a perplexing dilemma: **gross profit margins were consistently strong at 72% to 84%**, yet the business recorded a cumulative operating deficit of **-$7,659**. The founder asked: *"Are we genuinely profitable on each kilogram, or are we subsidizing sales with investor capital?"*

This investigation demonstrates the critical distinction between **Direct Material COGS** and **Fully-Absorbed Cost per kg**. While direct materials (sawdust, grain spawn, water, bags) cost only **$2.72 to $4.78 per kg**, fixed monthly overhead (facility lease, climate electricity, insurance, sanitation) averages **$2,073/month**. At low startup production volumes (sub-100 kg/mo), fully-absorbed cost per kg soared to **$35.31/kg**, far exceeding market wholesale prices. 

By modeling cost absorption against sales fulfillment, this case study establishes FungiFlow's **operational break-even threshold at 131.0 kg/month (30.3 kg/week)**, explaining why October 2024 generated the farm's first profitable operating result (+$1,521.98) when production scaled to 187.3 kg.

---

## 2. Baseline Data & Cost Absorption Trajectory

Querying [`case_studies/04_true_cost_per_kg_and_break_even/query.sql`](query.sql) generates the monthly cost absorption profile:

| Year-Month | Accepted Harvest (kg) | Sales Fulfilled (kg) | Direct Material COGS ($) | Fixed Facility OPEX ($) | Fully Absorbed Cost / Produced kg | Realized Revenue / Produced kg | Net Operating Result ($) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **2024-05** | 62.3 kg | 18.7 kg | $76.62 | $2,123.04 | **$35.31/kg** | $4.45/kg | -$1,922.34 |
| **2024-06** | 146.7 kg | 84.1 kg | $344.62 | $2,077.89 | **$16.51/kg** | $8.91/kg | -$1,115.00 |
| **2024-07** | 126.9 kg | 104.5 kg | $428.41 | $2,257.59 | **$21.17/kg** | $16.80/kg | -$554.02 |
| **2024-08** | 61.3 kg | 52.0 kg | $213.09 | $2,494.45 | **$44.17/kg** | $21.58/kg | -$1,384.59 |
| **2024-09** | 121.7 kg | 27.8 kg | $113.78 | $3,107.12 | **$26.47/kg** | $4.42/kg | -$2,683.28 |
| **2024-10** | 187.3 kg | 106.4 kg | $436.07 | $377.69* | **$4.34/kg** | $12.47/kg | **+$1,521.98** |

*\*Note: October OPEX reflects normalization of prepaid rent and utility credits.*

---

## 3. Mathematical Break-Even Model

To achieve commercial self-sustainability, the farm must generate enough gross contribution margin to absorb fixed overhead:

$$\text{Break-Even Volume (kg/month)} = \frac{\text{Fixed Monthly Overhead (OPEX)}}{\text{Weighted Contribution Margin per kg}}$$

### Variables Derived from Data:
- **Average Fixed Monthly Overhead**: $\text{OPEX}_{\text{fixed}} \approx \$2,073.00/\text{month}$
- **Weighted Average Realized ASP**: $\$20.12/\text{kg}$
- **Weighted Direct Material Cost**: $\$3.50/\text{kg}$
- **Weighted Contribution Margin ($/kg)**: $\$20.12 - \$3.50 = \mathbf{\$15.82/\text{kg}}$

### Calculation:
$$\text{Break-Even Monthly Volume} = \frac{\$2,073.00}{\$15.82/\text{kg}} = \mathbf{131.0\text{ kg/month}}$$
$$\text{Break-Even Weekly Inoculation} = \frac{131.0\text{ kg}}{4.33\text{ weeks}} = \mathbf{30.3\text{ kg/week}}$$

---

## 4. Operational & Managerial Takeaways

1. **Volume Scale is Non-Negotiable**: Fixed rent and baseload refrigeration operate as unavoidable fixed burdens. Cultivating fewer than 30 kg/week guarantees cash destruction.
2. **Minimum Order Quantities (MOQs)**: Deliveries under 2.5 kg fail to cover courier vehicle transit costs. Establish a 3kg MOQ for restaurant deliveries or apply a $7.50 small-order logistics surcharge.
3. **October Validation**: In October 2024, production reached 187.3 kg and fulfilled orders reached 106.4 kg. With fixed overhead spread over 187 kg, absorbed cost dropped to $4.34/kg, delivering the startup's maiden operating profit (+$1,521.98).

---

## 5. Interview Talking Points

> *"FungiFlow's founder was confused as to why the farm posted five straight months of losses despite an 80% gross margin. By conducting a fully-absorbed cost analysis, I showed that fixed rent and climate electricity averaged $2,073 per month. When harvest volumes were under 100 kg, the true absorbed cost per kg was $35 to $44, double the wholesale selling price. I calculated the precise commercial break-even threshold at 131 kg per month (30.3 kg/week), which directly aligned with the business reaching profitability in October once production scaled past 180 kg."*

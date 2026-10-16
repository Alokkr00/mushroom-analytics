# MycoMetrics - Phase 6: Advanced SQL Business Analytics & Reconciliation Findings

This document records the exact query results, biological findings, unit economics, and audit proofs executed against the transformed analytical warehouse.

## 01_production_biological_efficiency.sql - Query Statement 2
- **Execution Time**: 185.4 ms
- **Rows Returned**: 31

```
mushroom_common_name  variety_efficiency_rank  batch_id growing_room batch_status yield_performance_tier  cycle_duration_days  planned_blocks_count  dry_substrate_kg  total_accepted_harvest_kg  biological_efficiency_pct  target_biological_efficiency_pct  be_variance_from_target  rejection_rate_pct  direct_material_cost_per_kg
         Lion's Mane                        1 BAT-00009  Grow Room A    COMPLETED   High Yield Performer                   47                    26              26.0                     19.319                      74.30                              50.0                    24.30                5.41                       3.3366
         Lion's Mane                        2 BAT-00007  Grow Room A    COMPLETED   High Yield Performer                   50                    57              57.0                     41.738                      73.22                              50.0                    23.22                4.58                       3.2812
         Lion's Mane                        3 BAT-00015  Grow Room B    COMPLETED   High Yield Performer                   55                    26              26.0                     17.221                      66.23                              50.0                    16.23                6.60                       3.6641
         Lion's Mane                        4 BAT-00005  Grow Room B    COMPLETED   High Yield Performer                   47                    55              55.0                     34.134                      62.06                              50.0                    12.06                5.17                       4.0435
         Lion's Mane                        5 BAT-00010  Grow Room A    COMPLETED   High Yield Performer                   50                    23              23.0                     13.261                      57.66                              50.0                     7.66                4.04                       3.9137
         Lion's Mane                        6 BAT-00026  Grow Room A    COMPLETED   High Yield Performer                   39                    45              45.0                     24.384                      54.19                              50.0                     4.19                3.11                       4.9381
         Lion's Mane                        7 BAT-00028  Grow Room A    COMPLETED  Underperforming Batch                 <NA>                    24              24.0                      0.000                       0.00                              50.0                   -50.00                0.00                          NaN
         Lion's Mane                        7 BAT-00030  Grow Room A    COMPLETED  Underperforming Batch                 <NA>                    58              58.0                      0.000                       0.00                              50.0                   -50.00                0.00                          NaN
        Pearl Oyster                        1 BAT-00021  Grow Room B    COMPLETED   High Yield Performer                   41                    27              27.0                     27.801                     102.97                              75.0                    27.97                4.88                       2.4798
        Pearl Oyster                        2 BAT-00008  Grow Room A    COMPLETED   High Yield Performer                   38                    54              54.0                     54.975                     101.81                              75.0                    26.81                3.75                       2.2015
        Pearl Oyster                        3 BAT-00027  Grow Room B    COMPLETED   High Yield Performer                   38                    36              36.0                     34.467                      95.74                              75.0                    20.74                5.80                       2.3881
        Pearl Oyster                        4 BAT-00001  Grow Room A    COMPLETED   High Yield Performer                   32                    57              57.0                     53.675                      94.17                              75.0                    19.17                5.62                       2.6623
        Pearl Oyster                        5 BAT-00006  Grow Room A    COMPLETED   High Yield Performer                   39                    52              52.0                     48.331                      92.94                              75.0                    17.94                5.77                       2.3200
        Pearl Oyster                        6 BAT-00022  Grow Room B    COMPLETED   High Yield Performer                   35                    50              50.0                     46.115                      92.23                              75.0                    17.23                4.85                       2.7440
        Pearl Oyster                        7 BAT-00023  Grow Room B    COMPLETED   High Yield Performer                   39                    29              29.0                     25.804                      88.98                              75.0                    13.98                5.33                       2.6504
        Pearl Oyster                        8 BAT-00004  Grow Room A    COMPLETED   High Yield Performer                   34                    54              54.0                     46.445                      86.01                              75.0                    11.01                3.61                       3.2230
        Pearl Oyster                        9 BAT-00011  Grow Room A    COMPLETED   High Yield Performer                   34                    29              29.0                     24.651                      85.00                              75.0                    10.00                5.60                       3.0611
        Pearl Oyster                       10 BAT-00002  Grow Room B    COMPLETED   High Yield Performer                   37                    28              28.0                     22.736                      81.20                              75.0                     6.20                2.76                       3.3154
        Pearl Oyster                       11 BAT-00003  Grow Room A    COMPLETED   High Yield Performer                   36                    26              26.0                     20.663                      79.47                              75.0                     4.47                2.73                       2.9763
        Pearl Oyster                       12 BAT-00029  Grow Room A    COMPLETED  Underperforming Batch                 <NA>                    29              29.0                      0.000                       0.00                              75.0                   -75.00                0.00                          NaN
            Shiitake                        1 BAT-00012  Grow Room A    COMPLETED   High Yield Performer                   90                    46              46.0                     31.318                      68.08                              35.0                    33.08                2.07                       4.0236
            Shiitake                        2 BAT-00013  Grow Room B    COMPLETED   High Yield Performer                   86                    35              35.0                     22.554                      64.44                              35.0                    29.44                4.45                       3.8357
            Shiitake                        3 BAT-00016  Grow Room B    COMPLETED   High Yield Performer                   89                    32              32.0                     19.659                      61.43                              35.0                    26.43                2.90                       3.6197
            Shiitake                        4 BAT-00014  Grow Room B    COMPLETED   High Yield Performer                   90                    45              45.0                     26.993                      59.98                              35.0                    24.98                4.53                       4.2129
            Shiitake                        5 BAT-00017  Grow Room B    COMPLETED   High Yield Performer                   86                    32              32.0                     18.109                      56.59                              35.0                    21.59                2.63                       4.5845
            Shiitake                        6 BAT-00019  Grow Room A    COMPLETED   High Yield Performer                   72                    34              34.0                     15.404                      45.31                              35.0                    10.31                2.22                       5.3668
            Shiitake                        7 BAT-00020  Grow Room A    COMPLETED   High Yield Performer                   68                    44              44.0                     16.400                      37.27                              35.0                     2.27                4.87                       6.2927
            Shiitake                        8 BAT-00018  Grow Room A    COMPLETED  Underperforming Batch                 <NA>                    30              30.0                      0.000                       0.00                              35.0                   -35.00                0.00                          NaN
            Shiitake                        8 BAT-00024  Grow Room B    COMPLETED  Underperforming Batch                 <NA>                    50              50.0                      0.000                       0.00                              35.0                   -35.00                0.00                          NaN
            Shiitake                        8 BAT-00025  Grow Room B    COMPLETED  Underperforming Batch                 <NA>                    58              58.0                      0.000                       0.00                              35.0                   -35.00                0.00                          NaN
            Shiitake                        8 BAT-00031  Grow Room B    COMPLETED  Underperforming Batch                 <NA>                    39              39.0                      0.000                       0.00                              35.0                   -35.00                0.00                          NaN
```

## 02_cost_per_kg_and_unit_economics.sql - Query Statement 2
- **Execution Time**: 63.7 ms
- **Rows Returned**: 3

```
mushroom_common_name        sku_code                           product_name package_format  unit_weight_kg  total_kg_sold  realized_asp_per_kg  avg_direct_material_cost_per_kg  allocated_overhead_per_kg  fully_absorbed_cost_per_kg  unit_contribution_margin_per_kg  fully_absorbed_profit_per_kg  realized_gross_margin_pct
         Lion's Mane MSH-02-WHL-01KG  Lion's Mane Bulk Wholesale Crate 1 kg     Bulk Crate             1.0        104.827                25.56                             5.25                        NaN                         NaN                            20.31                           NaN                      83.96
        Pearl Oyster MSH-01-WHL-01KG Pearl Oyster Bulk Wholesale Crate 1 kg     Bulk Crate             1.0        179.662                15.24                             2.84                        NaN                         NaN                            12.40                           NaN                      73.10
            Shiitake MSH-03-WHL-01KG     Shiitake Bulk Wholesale Crate 1 kg     Bulk Crate             1.0        108.819                22.93                             7.33                        NaN                         NaN                            15.60                           NaN                      82.12
```

## 03_revenue_pricing_and_channel_margins.sql - Query Statement 2
- **Execution Time**: 58.2 ms
- **Rows Returned**: 4

```
   sales_channel customer_segment  total_orders  fulfilled_kg  gross_invoiced_revenue  promotional_discounts  discount_rate_pct  quality_credit_refunds  return_credit_rate_pct  final_recognized_revenue  gross_profit  gross_margin_pct  net_effective_asp_per_kg
Wholesale Direct       Restaurant            38       268.109                 5703.91                 326.84               5.73                   72.12                    1.26                   5304.95       4205.70             79.28                     19.79
Wholesale Direct  Boutique Grocer            20       105.575                 2167.74                   0.00               0.00                    0.00                    0.00                   2167.74       1734.88             80.03                     20.53
   Market Direct   Farmers Market             9        10.298                  238.04                   0.00               0.00                    0.00                    0.00                    238.04        195.82             82.26                     23.12
             D2C  Direct Consumer             8         9.326                  206.91                   0.00               0.00                    4.54                    2.19                    202.37        164.13             81.10                     21.70
```

## 03_revenue_pricing_and_channel_margins.sql - Query Statement 3
- **Execution Time**: 43.0 ms
- **Rows Returned**: 66

```
order_date mushroom_common_name  transactions_count  total_kg_delivered  day_revenue  day_avg_asp_per_kg  smoothed_trend_asp_per_kg
2024-10-27             Shiitake                   5               19.24       454.05               23.76                      23.86
2024-10-24             Shiitake                   3               12.69       304.48               24.00                      23.89
2024-10-23         Pearl Oyster                   1                0.18         2.85               16.01                      14.96
2024-10-23             Shiitake                   1                0.31         7.32               24.00                      23.34
2024-10-18             Shiitake                   2                1.39        33.24               24.01                      23.34
2024-10-16             Shiitake                   2                7.15       171.48               24.00                      23.34
2024-10-13         Pearl Oyster                   1                4.17        66.64               16.00                      14.96
2024-10-13             Shiitake                   3               19.90       441.03               22.46                      23.68
2024-10-11         Pearl Oyster                   1                1.15        18.40               16.00                      14.96
2024-10-11             Shiitake                   2                1.51        36.12               24.01                      24.00
2024-10-10         Pearl Oyster                   1                2.03        32.54               16.00                      14.46
2024-10-07         Pearl Oyster                   1                1.86        29.70               16.00                      14.46
2024-10-07             Shiitake                   1                4.74       113.86               24.00                      22.54
2024-10-06             Shiitake                   3               17.88       429.21               24.00                      22.54
2024-10-05             Shiitake                   2                2.19        52.49               24.00                      22.42
2024-10-01         Pearl Oyster                   1                9.99       142.32               14.25                      14.46
2024-09-30             Shiitake                   1                7.06        97.05               13.76                      21.95
2024-09-28         Pearl Oyster                   1                1.59        16.63               10.45                      14.45
2024-09-24             Shiitake                   2                9.77       234.53               24.00                      24.00
2024-09-20         Pearl Oyster                   1                2.14        34.26               16.00                      15.24
2024-09-20             Shiitake                   1                4.79       114.94               24.00                      23.99
2024-09-19         Pearl Oyster                   1                2.19        34.98               16.00                      15.00
2024-09-17             Shiitake                   1                0.22         5.23               23.99                      23.99
2024-08-26          Lion's Mane                   1                6.35       155.36               24.49                      26.64
2024-08-20          Lion's Mane                   4                2.62        70.72               27.00                      26.75
2024-08-17          Lion's Mane                   3                3.65        98.47               27.00                      25.99
2024-08-16          Lion's Mane                   1                1.98        53.33               27.00                      25.99
2024-08-15          Lion's Mane                   1                6.83       166.96               24.45                      25.99
2024-08-13          Lion's Mane                   2               12.23       302.07               24.73                      26.50
2024-08-12          Lion's Mane                   1                3.78       102.06               27.00                      27.00
2024-08-11          Lion's Mane                   2                1.48        39.94               27.01                      27.00
2024-08-10          Lion's Mane                   3                7.51       202.66               27.00                      26.90
2024-08-06          Lion's Mane                   1                1.48        40.04               27.00                      26.71
2024-08-04          Lion's Mane                   2                1.82        49.14               27.00                      26.28
2024-08-02          Lion's Mane                   2                0.96        25.90               27.01                      26.19
2024-08-02         Pearl Oyster                   1                1.30        16.29               12.51                      15.00
2024-07-30          Lion's Mane                   3               18.89       471.78               25.32                      26.02
2024-07-29          Lion's Mane                   3               12.13       314.70               26.54                      26.04
2024-07-29         Pearl Oyster                   1                1.90        30.35               16.00                      15.50
2024-07-27         Pearl Oyster                   1                1.98        31.68               16.00                      15.50
2024-07-26         Pearl Oyster                   1                6.68        94.65               14.17                      15.50
2024-07-25         Pearl Oyster                   1                4.99        79.89               16.00                      15.76
2024-07-23          Lion's Mane                   1                9.83       247.63               25.20                      25.94
2024-07-22          Lion's Mane                   1                3.99       107.78               27.00                      26.18
2024-07-20          Lion's Mane                   1                0.78        21.17               27.00                      25.78
2024-07-19          Lion's Mane                   1                8.54       209.62               24.55                      24.55
2024-07-14         Pearl Oyster                   2                7.93       115.57               15.15                      15.88
2024-07-13         Pearl Oyster                   2                6.86       109.72               16.00                      15.77
2024-07-11         Pearl Oyster                   1                1.49        23.84               16.00                      15.53
2024-07-10         Pearl Oyster                   4               10.97       164.62               15.59                      15.43
2024-07-01         Pearl Oyster                   2                7.53       108.98               15.18                      15.64
2024-06-29         Pearl Oyster                   2               10.85       167.46               15.55                      15.87
2024-06-28         Pearl Oyster                   1                0.77        12.29               16.00                      16.00
2024-06-27         Pearl Oyster                   3               12.93       206.84               16.00                      15.88
2024-06-25         Pearl Oyster                   2                1.54        24.62               16.00                      15.51
2024-06-21         Pearl Oyster                   1                6.49       103.79               16.00                      15.30
2024-06-19         Pearl Oyster                   1                0.48         7.74               15.99                      15.30
2024-06-18         Pearl Oyster                   2                7.35       110.96               15.38                      15.39
2024-06-17         Pearl Oyster                   2               13.84       202.47               14.65                      15.60
2024-06-07         Pearl Oyster                   3               12.37       192.29               15.69                      15.83
2024-06-04         Pearl Oyster                   2                9.76       156.13               16.00                      15.58
2024-06-01         Pearl Oyster                   2                7.68       122.92               16.00                      15.46
2024-05-30         Pearl Oyster                   1                7.22       105.70               14.65                      15.26
2024-05-27         Pearl Oyster                   1                2.99        47.89               16.00                      15.46
2024-05-25         Pearl Oyster                   1                7.37       105.91               14.38                      15.19
2024-05-24         Pearl Oyster                   1                1.11        17.82               16.00                      16.00
```

## 04_customer_cohort_retention_and_rfm.sql - Query Statement 2
- **Execution Time**: 74.0 ms
- **Rows Returned**: 17

```
cohort_month  cohort_size  months_since_acquisition  active_customers  retention_rate_pct
     2024-05            4                         0                 4               100.0
     2024-05            4                         1                 2                50.0
     2024-05            4                         2                 3                75.0
     2024-05            4                         3                 3                75.0
     2024-05            4                         4                 2                50.0
     2024-05            4                         5                 4               100.0
     2024-06            8                         0                 8               100.0
     2024-06            8                         1                 3                37.5
     2024-06            8                         2                 3                37.5
     2024-06            8                         3                 3                37.5
     2024-06            8                         4                 3                37.5
     2024-07            3                         0                 3               100.0
     2024-07            3                         1                 3               100.0
     2024-07            3                         2                 1                33.3
     2024-07            3                         3                 2                66.7
     2024-08            2                         0                 2               100.0
     2024-10            1                         0                 1               100.0
```

## 04_customer_cohort_retention_and_rfm.sql - Query Statement 3
- **Execution Time**: 66.8 ms
- **Rows Returned**: 18

```
customer_id                customer_name customer_segment          customer_rfm_segment  recency_days  frequency_orders  monetary_revenue  r_score  f_score  m_score
    CUS-002            The Umami Kitchen       Restaurant                Loyal Regulars            14                 4           1118.59        3        2        4
    CUS-005     Green Plate Farm Kitchen       Restaurant At Risk (High Value, Lapsing)            17                 7           1116.54        2        4        4
    CUS-019         Terra Firma Wellness  Boutique Grocer      Champions (Top Accounts)            16                 6            840.39        3        4        4
    CUS-018         Anchor & Grain Diner       Restaurant      Champions (Top Accounts)             0                 7            811.70        4        4        4
    CUS-009   Natural Roots Health Store  Boutique Grocer      Champions (Top Accounts)             3                 6            754.22        4        4        3
    CUS-004          Harvest Table Co-op       Restaurant      Champions (Top Accounts)             0                 5            728.64        4        3        3
    CUS-017            Bloom & Root Cafe       Restaurant      Champions (Top Accounts)            11                 5            589.70        3        3        3
    CUS-008              The Good Pantry  Boutique Grocer At Risk (High Value, Lapsing)            33                 6            463.81        2        3        3
    CUS-016         Cloudforest Soup Co.       Restaurant   Low Engagement / Occasional            73                 3            369.39        1        2        2
    CUS-003              Fernwood Bistro       Restaurant   Low Engagement / Occasional            22                 4            309.28        2        2        2
    CUS-001      Sage & Ember Restaurant       Restaurant   Low Engagement / Occasional           131                 3            261.11        1        1        2
    CUS-010 Sunrise Farmers Market Stall   Farmers Market                Loyal Regulars            16                 6            168.78        3        3        2
    CUS-006       Verdant Greens Grocery  Boutique Grocer   Low Engagement / Occasional            78                 1             96.28        1        1        2
    CUS-015       Priya Wellness Kitchen  Direct Consumer   Low Engagement / Occasional            40                 4             81.05        2        2        1
    CUS-013         Elena's Home Kitchen  Direct Consumer   Low Engagement / Occasional            68                 2             71.39        2        1        1
    CUS-011     Weekend Community Market   Farmers Market                Loyal Regulars             4                 3             69.26        4        2        1
    CUS-014               Marcus D'Souza  Direct Consumer   Low Engagement / Occasional            86                 2             49.93        1        1        1
    CUS-007            Wild Earth Market  Boutique Grocer   Low Engagement / Occasional           124                 1             13.04        1        1        1
```

## 05_inventory_spoilage_and_shelf_life_decay.sql - Query Statement 2
- **Execution Time**: 38.3 ms
- **Rows Returned**: 22

```
              loss_stage mushroom_common_name                                    reason_code  total_incidents  total_lost_kg  total_loss_amount  loss_pct_of_gross_harvest  stage_loss_rank
   COLD_STORAGE_SPOILAGE         Pearl Oyster           Power interruption - chiller failure              3.0         21.980             222.17                       2.97                1
   COLD_STORAGE_SPOILAGE         Pearl Oyster         Bacterial blotch detected post-packing              2.0         27.490             194.98                       3.72                2
   COLD_STORAGE_SPOILAGE         Pearl Oyster Over-order correction - unsold stock write-off              2.0         19.976             116.82                       2.70                3
   COLD_STORAGE_SPOILAGE         Pearl Oyster    Cold storage spoilage - shelf life exceeded              2.0         19.013             110.07                       2.57                4
   COLD_STORAGE_SPOILAGE         Pearl Oyster               Physical damage during packaging              2.0         13.201             109.10                       1.79                5
   COLD_STORAGE_SPOILAGE          Lion's Mane    Cold storage spoilage - shelf life exceeded              1.0         12.849              93.54                       1.74                6
   COLD_STORAGE_SPOILAGE             Shiitake    Cold storage spoilage - shelf life exceeded              1.0          7.444              69.14                       1.01                7
CUSTOMER_DELIVERY_RETURN             Shiitake           Excess order - customer over-ordered              1.0          2.637              63.29                       0.36                1
   COLD_STORAGE_SPOILAGE             Shiitake         Bacterial blotch detected post-packing              1.0          4.723              50.67                       0.64                8
 HARVEST_FLOOR_REJECTION         Pearl Oyster                               Bacterial blotch              8.0          7.720              27.02                       1.04                1
 HARVEST_FLOOR_REJECTION         Pearl Oyster                       Spore drop contamination              8.0          7.574              26.51                       1.02                2
 HARVEST_FLOOR_REJECTION         Pearl Oyster                              Physical bruising              6.0          4.785              16.74                       0.65                3
   COLD_STORAGE_SPOILAGE             Shiitake               Physical damage during packaging              1.0          1.619              13.93                       0.22                9
   COLD_STORAGE_SPOILAGE          Lion's Mane Over-order correction - unsold stock write-off              1.0          1.640              13.41                       0.22               10
 HARVEST_FLOOR_REJECTION          Lion's Mane                       Spore drop contamination              5.0          3.496              12.25                       0.47                4
 HARVEST_FLOOR_REJECTION          Lion's Mane                               Bacterial blotch              4.0          3.473              12.16                       0.47                5
 HARVEST_FLOOR_REJECTION             Shiitake                       Spore drop contamination              7.0          2.982              10.44                       0.40                6
CUSTOMER_DELIVERY_RETURN         Pearl Oyster           Excess order - customer over-ordered              1.0          0.552               8.83                       0.07                2
CUSTOMER_DELIVERY_RETURN         Pearl Oyster                   Damaged packaging on arrival              1.0          0.284               4.54                       0.04                3
 HARVEST_FLOOR_REJECTION             Shiitake                               Bacterial blotch              2.0          1.248               4.37                       0.17                7
 HARVEST_FLOOR_REJECTION             Shiitake                              Physical bruising              3.0          1.032               3.62                       0.14                8
 HARVEST_FLOOR_REJECTION          Lion's Mane                              Physical bruising              2.0          0.559               1.96                       0.08                9
```

## 05_inventory_spoilage_and_shelf_life_decay.sql - Query Statement 3
- **Execution Time**: 73.4 ms
- **Rows Returned**: 45

```
   lot_id                           product_name mushroom_common_name package_format last_movement_date expiry_date  current_available_stock_kg  days_until_expiration          inventory_risk_status
LOT-00043  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-10-28  2024-11-04                      24.384                      5 MODERATE - High Sales Priority
LOT-00001 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-05-31  2024-05-29                      21.961                   -154    EXPIRED - Condemn & Compost
LOT-00011 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-07-03  2024-07-04                      17.274                   -118    EXPIRED - Condemn & Compost
LOT-00040 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-09-26  2024-10-01                      16.417                    -29    EXPIRED - Condemn & Compost
LOT-00036     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-28  2024-11-07                      16.400                      8          HEALTHY - Fresh Stock
LOT-00015 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-07-04  2024-07-04                      12.233                   -118    EXPIRED - Condemn & Compost
LOT-00044 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-10-04  2024-10-02                      11.652                    -28    EXPIRED - Condemn & Compost
LOT-00045 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-10-10  2024-10-12                      10.972                    -18    EXPIRED - Condemn & Compost
LOT-00037 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-10-02  2024-09-30                       7.025                    -30    EXPIRED - Condemn & Compost
LOT-00024     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-30  2024-11-05                       6.680                      6 MODERATE - High Sales Priority
LOT-00039 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-09-25  2024-09-23                       5.716                    -37    EXPIRED - Condemn & Compost
LOT-00007 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-06-05  2024-06-03                       4.462                   -149    EXPIRED - Condemn & Compost
LOT-00038 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-10-14  2024-10-11                       3.683                    -19    EXPIRED - Condemn & Compost
LOT-00019  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-11  2024-08-11                       3.221                    -80    EXPIRED - Condemn & Compost
LOT-00002 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-06-08  2024-06-07                       3.183                   -145    EXPIRED - Condemn & Compost
LOT-00016 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-07-17  2024-07-15                       3.056                   -107    EXPIRED - Condemn & Compost
LOT-00008 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-06-11  2024-06-10                       2.859                   -142    EXPIRED - Condemn & Compost
LOT-00010  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-07  2024-08-06                       2.710                    -85    EXPIRED - Condemn & Compost
LOT-00042 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-10-27  2024-10-24                       2.148                     -6    EXPIRED - Condemn & Compost
LOT-00013  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-07  2024-08-05                       2.066                    -86    EXPIRED - Condemn & Compost
LOT-00035     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-30  2024-10-29                       1.677                     -1    EXPIRED - Condemn & Compost
LOT-00023     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-22  2024-10-21                       1.626                     -9    EXPIRED - Condemn & Compost
LOT-00026     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-30  2024-10-29                       1.528                     -1    EXPIRED - Condemn & Compost
LOT-00033     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-09-26  2024-09-24                       1.324                    -36    EXPIRED - Condemn & Compost
LOT-00041 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-10-16  2024-10-14                       1.083                    -16    EXPIRED - Condemn & Compost
LOT-00022 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-08-06  2024-08-06                       0.617                    -85    EXPIRED - Condemn & Compost
LOT-00029  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-23  2024-08-21                       0.507                    -70    EXPIRED - Condemn & Compost
LOT-00020  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-23  2024-08-24                       0.317                    -67    EXPIRED - Condemn & Compost
LOT-00027     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-03  2024-10-02                       0.274                    -28    EXPIRED - Condemn & Compost
LOT-00003 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-06-23  2024-06-22                       0.000                   -130    Depleted / Fully Dispatched
LOT-00005 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-06-21  2024-06-22                       0.000                   -130    Depleted / Fully Dispatched
LOT-00004 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-07-02  2024-06-29                       0.000                   -123    Depleted / Fully Dispatched
LOT-00006 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-06-30  2024-07-02                       0.000                   -120    Depleted / Fully Dispatched
LOT-00012 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-07-17  2024-07-15                       0.000                   -107    Depleted / Fully Dispatched
LOT-00009  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-07-26  2024-07-25                       0.000                    -97    Depleted / Fully Dispatched
LOT-00021 Pearl Oyster Bulk Wholesale Crate 1 kg         Pearl Oyster     Bulk Crate         2024-07-31  2024-07-30                       0.000                    -92    Depleted / Fully Dispatched
LOT-00017  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-01  2024-08-02                       0.000                    -89    Depleted / Fully Dispatched
LOT-00018  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-17  2024-08-14                       0.000                    -77    Depleted / Fully Dispatched
LOT-00014  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-17  2024-08-17                       0.000                    -74    Depleted / Fully Dispatched
LOT-00030  Lion's Mane Bulk Wholesale Crate 1 kg          Lion's Mane     Bulk Crate         2024-08-28  2024-09-01                       0.000                    -59    Depleted / Fully Dispatched
LOT-00034     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-03  2024-10-08                       0.000                    -22    Depleted / Fully Dispatched
LOT-00028     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-09  2024-10-14                       0.000                    -16    Depleted / Fully Dispatched
LOT-00025     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-16  2024-10-16                       0.000                    -14    Depleted / Fully Dispatched
LOT-00031     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-16  2024-10-16                       0.000                    -14    Depleted / Fully Dispatched
LOT-00032     Shiitake Bulk Wholesale Crate 1 kg             Shiitake     Bulk Crate         2024-10-30  2024-10-28                       0.000                     -2    Depleted / Fully Dispatched
```

## 06_cash_burn_runway_and_working_capital.sql - Query Statement 2
- **Execution Time**: 64.8 ms
- **Rows Returned**: 6

```
year_month  cash_inflow_sales  total_cash_outflow  net_cash_burn  cumulative_cash_position  trailing_3m_avg_burn       cash_flow_status
   2024-05             277.32             2420.07       -2142.75                  -2142.75              -2142.75       Cash Burning (-)
   2024-06            1307.51             2368.59       -1061.08                  -3203.83              -1601.92       Cash Burning (-)
   2024-07            2131.98             2450.70        -318.72                  -3522.55              -1174.18       Cash Burning (-)
   2024-08            1322.94             2674.05       -1351.11                  -4873.66               -910.30       Cash Burning (-)
   2024-09             537.62             3263.67       -2726.05                  -7599.71              -1465.29       Cash Burning (-)
   2024-10            2335.73              607.20        1728.53                  -5871.18               -782.88 Cash Flow Positive (+)
```

## 06_cash_burn_runway_and_working_capital.sql - Query Statement 3
- **Execution Time**: 68.1 ms
- **Rows Returned**: 44

```
year_month           category_name      cost_behavior  monthly_spend  prior_month_spend  mom_change_pct
   2024-05      Business Insurance     Fixed Overhead          95.00                NaN             NaN
   2024-06      Business Insurance     Fixed Overhead          95.00              95.00             0.0
   2024-07      Business Insurance     Fixed Overhead          95.00              95.00             0.0
   2024-08      Business Insurance     Fixed Overhead          95.00              95.00             0.0
   2024-09      Business Insurance     Fixed Overhead          95.00              95.00             0.0
   2024-10      Business Insurance     Fixed Overhead          95.00              95.00             0.0
   2024-05             Electricity     Fixed Overhead         408.12                NaN             NaN
   2024-06             Electricity     Fixed Overhead         481.05             408.12            17.9
   2024-07             Electricity     Fixed Overhead         442.41             481.05            -8.0
   2024-08             Electricity     Fixed Overhead         783.02             442.41            77.0
   2024-09             Electricity     Fixed Overhead         411.27             783.02           -47.5
   2024-06   Equipment Maintenance     Fixed Overhead          64.22                NaN             NaN
   2024-08   Equipment Maintenance     Fixed Overhead          70.85              64.22            10.3
   2024-05           Facility Rent     Fixed Overhead        1200.00                NaN             NaN
   2024-06           Facility Rent     Fixed Overhead        1200.00            1200.00             0.0
   2024-07           Facility Rent     Fixed Overhead        1200.00            1200.00             0.0
   2024-08           Facility Rent     Fixed Overhead        1200.00            1200.00             0.0
   2024-09           Facility Rent     Fixed Overhead        2400.00            1200.00           100.0
   2024-05  Hygiene & Sanitization Variable Operating          43.32                NaN             NaN
   2024-07  Hygiene & Sanitization Variable Operating          68.31              43.32            57.7
   2024-10  Hygiene & Sanitization Variable Operating          63.25              68.31            -7.4
   2024-05   Local Delivery & Fuel Variable Operating          47.82                NaN             NaN
   2024-06   Local Delivery & Fuel Variable Operating          98.25              47.82           105.5
   2024-07   Local Delivery & Fuel Variable Operating         133.46              98.25            35.8
   2024-08   Local Delivery & Fuel Variable Operating         101.32             133.46           -24.1
   2024-09   Local Delivery & Fuel Variable Operating          45.08             101.32           -55.5
   2024-05 Marketing & Market Fees Variable Operating          37.95                NaN             NaN
   2024-06 Marketing & Market Fees Variable Operating          18.34              37.95           -51.7
   2024-08 Marketing & Market Fees Variable Operating          99.83              18.34           444.3
   2024-10 Marketing & Market Fees Variable Operating          83.36              99.83           -16.5
   2024-05     Miscellaneous Admin     Fixed Overhead          78.54                NaN             NaN
   2024-06     Miscellaneous Admin     Fixed Overhead          63.08              78.54           -19.7
   2024-07     Miscellaneous Admin     Fixed Overhead          84.95              63.08            34.7
   2024-08     Miscellaneous Admin     Fixed Overhead          75.14              84.95           -11.5
   2024-09     Miscellaneous Admin     Fixed Overhead          87.50              75.14            16.4
   2024-10     Miscellaneous Admin     Fixed Overhead          65.76              87.50           -24.8
   2024-05     Packaging Materials Variable Operating         141.26                NaN             NaN
   2024-07     Packaging Materials Variable Operating         177.32             141.26            25.5
   2024-05       Water & Utilities     Fixed Overhead          71.03                NaN             NaN
   2024-06       Water & Utilities     Fixed Overhead          57.95              71.03           -18.4
   2024-07       Water & Utilities     Fixed Overhead          56.14              57.95            -3.1
   2024-08       Water & Utilities     Fixed Overhead          69.29              56.14            23.4
   2024-09       Water & Utilities     Fixed Overhead          68.27              69.29            -1.5
   2024-10       Water & Utilities     Fixed Overhead          70.32              68.27             3.0
```

## 07_scenario_sensitivity_and_decision_models.sql - Query Statement 2
- **Execution Time**: 26.2 ms
- **Rows Returned**: 1

```
 historical_lost_crop_kg  historical_direct_waste_loss  foregone_revenue_potential  saved_marketable_crop_kg_50pct  direct_cash_savings_50pct  incremental_revenue_unlocked_50pct  net_annual_economic_gain_est
                  166.28                       1185.56                     2992.99                           83.14                     592.78                             1496.49                       1715.15
```

## 07_scenario_sensitivity_and_decision_models.sql - Query Statement 3
- **Execution Time**: 36.6 ms
- **Rows Returned**: 3

```
mushroom_common_name  current_bulk_kg  current_bulk_rev  bulk_asp_per_kg  shifted_volume_kg  new_retail_punnet_revenue  displaced_bulk_revenue  incremental_revenue_gain
        Pearl Oyster          179.662           2738.74            15.24              44.92                    1437.30                  684.51                    752.78
            Shiitake          108.819           2495.03            22.93              27.20                     870.55                  623.80                    246.75
         Lion's Mane          104.827           2679.33            25.56              26.21                     838.62                  669.84                    168.77
```

## financial_reconciliation.sql - Query Statement 1
- **Execution Time**: 98.8 ms
- **Rows Returned**: 1

```
           reconciliation_check  raw_net_invoiced  staging_net_invoiced  intermediate_recognized_revenue  fact_recognized_revenue  mart_recognized_revenue  fact_to_mart_variance                      audit_status
REVENUE_PIPELINE_RECONCILIATION           9754.77               7989.76                           7913.1                   7913.1                   7913.1                    0.0 RECONCILED - ZERO VARIANCE [PASS]
```

## financial_reconciliation.sql - Query Statement 2
- **Execution Time**: 12.2 ms
- **Rows Returned**: 1

```
               reconciliation_check  raw_accepted_kg  fact_accepted_kg  mart_accepted_kg  fact_to_mart_variance_kg                      audit_status
HARVEST_MASS_BALANCE_RECONCILIATION          706.157           706.157           706.157                       0.0 RECONCILED - ZERO VARIANCE [PASS]
```

## financial_reconciliation.sql - Query Statement 3
- **Execution Time**: 11.7 ms
- **Rows Returned**: 1

```
         reconciliation_check  raw_total_opex  fact_total_opex  mart_total_opex  fact_to_mart_variance                      audit_status
OPEX_FINANCIAL_RECONCILIATION        12437.78         12437.78         12437.78                    0.0 RECONCILED - ZERO VARIANCE [PASS]
```


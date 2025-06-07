## **Anomaly Detection**

The **decoy_flag** and **decoy_noise** columns allow to identify two different kinds of anomalies:<p>

1. **Simulation Noise**: Customers with **`decoy_flag = 1`** shows extreme payment values and irrational **`decoy_noise`** levels. This suggests that when training the model, false or unusual data should be avoided.

2. **Customer Outliers**: All of the customers with payment_values that are significantly than average (top 1%) have **`decoy_flag = 1`**, which supports the notion that these transactions are not typical.

**`Recommendations`**:

**`decoy_flag = 1`** transactions should be avoided for customer analysis and model training.
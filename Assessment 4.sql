/* =========================================================
   Assessment_Q4.sql – Simplified CLV
   CLV formula provided:
       profit_per_tx      = 0.1 % of the transaction value
       estimated_clv      = (total_tx / tenure_months) * 12 * avg_profit_per_tx
   Output:
       customer_id | name | tenure_months | total_transactions | estimated_clv
   ========================================================= */

/* ---------- STEP 1: Tenure (months since signup) ---------- */
CREATE TEMPORARY TABLE cust_tenure
SELECT
    id            AS customer_id,
    name,
    -- Tenure in full months = (years * 12) + months
    TIMESTAMPDIFF(MONTH, date_joined, CURDATE()) AS tenure_months
FROM users_customuser;

/* ---------- STEP 2: Total transactions & volume ----------- */
CREATE TEMPORARY TABLE cust_tx
SELECT
    owner_id      AS customer_id,
    COUNT(*)      AS total_transactions,
    SUM(confirmed_amount) / 100.0 AS total_volume_naira      -- kobo → ₦
FROM savings_savingsaccount
GROUP BY owner_id;

/* ---------- STEP 3: Combine & compute CLV ----------------- */
SELECT
    c.customer_id,
    c.name,
    c.tenure_months,
    COALESCE(t.total_transactions, 0) AS total_transactions,
    
    /* ---- estimated CLV ---- */
    CASE
      WHEN c.tenure_months = 0 OR t.total_transactions IS NULL THEN 0
      ELSE
        /* avg tx value (₦)            */ (t.total_volume_naira / t.total_transactions) * 0.001   -- 0.1 %
        /* annualised tx rate (count)  */ * (t.total_transactions / c.tenure_months) * 12
    END AS estimated_clv
FROM cust_tenure  c
LEFT JOIN cust_tx t ON t.customer_id = c.customer_id
ORDER BY estimated_clv DESC;

/* ---------- Clean-up (optional) --------------------------- */
DROP TEMPORARY TABLE cust_tenure;
DROP TEMPORARY TABLE cust_tx;
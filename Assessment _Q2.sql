/* =========================================================
   Assessment_Q2.sql  
   Transaction-frequency buckets: High / Medium / Low
   ========================================================= */

/* -------- STEP 1: transactions per customer-month -------- */
CREATE TEMPORARY TABLE tx_per_month
SELECT
    owner_id,
    DATE_FORMAT(transaction_date, '%Y-%m-01') AS month_start,
    COUNT(*)                                  AS tx_count
FROM savings_savingsaccount
GROUP BY owner_id, month_start;

/* -------- STEP 2: average transactions per customer ------ */
CREATE TEMPORARY TABLE avg_tx
SELECT
    owner_id,
    AVG(tx_count) AS avg_tx_per_month
FROM tx_per_month
GROUP BY owner_id;

/* -------- STEP 3 & 4: label + aggregate ------------------ */
SELECT
    CASE
        WHEN a.avg_tx_per_month >= 10 THEN 'High Frequency'
        WHEN a.avg_tx_per_month >= 3  THEN 'Medium Frequency'
        ELSE                              'Low Frequency'
    END                         AS frequency_category,
    COUNT(*)                    AS customer_count,
    ROUND(AVG(a.avg_tx_per_month), 1) AS avg_transactions_per_month
FROM avg_tx AS a
GROUP BY frequency_category
ORDER BY FIELD(frequency_category,
               'High Frequency', 'Medium Frequency', 'Low Frequency');

/* -------- cleanup (optional) ----------------------------- */
DROP TEMPORARY TABLE tx_per_month;
DROP TEMPORARY TABLE avg_tx;

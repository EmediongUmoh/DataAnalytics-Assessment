/* =========================================================
   Assessment_Q3.sql   –   Inactive Savings / Investment Plans
   Goal: list every active savings owner or investment plan
         that has had no inflow or outflow in > 365 days.
   Output columns:
         plan_id, owner_id, type, last_transaction_date, inactivity_days
   ========================================================= */

/* ---------- 1.  LAST transaction per Savings owner -------- */
CREATE TEMPORARY TABLE last_savings
SELECT
    NULL        AS plan_id,          -- savings aren't stored per-plan
    owner_id,
    'Savings'   AS type,
    MAX(transaction_date) AS last_tx
FROM savings_savingsaccount
GROUP BY owner_id;

/* ---------- 2.  LAST transaction per Investment plan ------ */
/* Build a single table of *all* investment flows (deposits + withdrawals) */
CREATE TEMPORARY TABLE invest_flows
SELECT plan_id, transaction_date
FROM savings_savingsaccount
UNION ALL
SELECT plan_id, transaction_date
FROM withdrawals_withdrawal;

/* Now pick the most-recent date for each investment plan */
CREATE TEMPORARY TABLE last_investment
SELECT
    p.id        AS plan_id,
    p.owner_id,
    'Investment' AS type,
    MAX(f.transaction_date) AS last_tx
FROM plans_plan p
LEFT JOIN invest_flows f ON f.plan_id = p.id
WHERE p.is_a_fund = 1                      -- keep only investment plans
GROUP BY p.id, p.owner_id;

/* ---------- 3.  Combine both tables & flag inactivity ------ */
SELECT
    ls.plan_id,
    ls.owner_id,
    ls.type,
    ls.last_tx       AS last_transaction_date,
    DATEDIFF(CURDATE(), ls.last_tx) AS inactivity_days
FROM last_savings ls
WHERE ls.last_tx < DATE_SUB(CURDATE(), INTERVAL 365 DAY)

UNION ALL

SELECT
    li.plan_id,
    li.owner_id,
    li.type,
    li.last_tx       AS last_transaction_date,
    DATEDIFF(CURDATE(), li.last_tx) AS inactivity_days
FROM last_investment li
WHERE li.last_tx < DATE_SUB(CURDATE(), INTERVAL 365 DAY)

ORDER BY inactivity_days DESC;

/* ---------- 4.  Clean-up (optional) ------------------------ */
DROP TEMPORARY TABLE last_savings;
DROP TEMPORARY TABLE invest_flows;
DROP TEMPORARY TABLE last_investment;

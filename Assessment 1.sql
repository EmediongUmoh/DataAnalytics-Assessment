/*============================================================
   Assessment_Q1.sql  
  ============================================================*/

SELECT
    u.id                                  AS owner_id,
    u.name,
    sp.savings_count,
    ip.investment_count,
    COALESCE(td.total_deposits,0)         AS total_deposits
FROM users_customuser u

/* ---- savings plans with ≥1 deposit ---- */
JOIN (
       SELECT p.owner_id,
              COUNT(DISTINCT p.id) AS savings_count
       FROM   plans_plan            p
       JOIN   savings_savingsaccount s
              ON s.plan_id = p.id
       WHERE  p.is_regular_savings = 1
         AND  s.confirmed_amount  > 0
       GROUP BY p.owner_id
     ) sp ON sp.owner_id = u.id

/* ---- investment plans with ≥1 deposit ---- */
JOIN (
       SELECT p.owner_id,
              COUNT(DISTINCT p.id) AS investment_count
       FROM   plans_plan            p
       JOIN   savings_savingsaccount s
              ON s.plan_id = p.id
       WHERE  p.is_a_fund       = 1
         AND  s.confirmed_amount > 0
       GROUP BY p.owner_id
     ) ip ON ip.owner_id = u.id

/* ---- total deposits (all plans) ---- */
LEFT JOIN (
            SELECT s.owner_id,
                   SUM(s.confirmed_amount)/100.0 AS total_deposits
            FROM   savings_savingsaccount s
            WHERE  s.confirmed_amount > 0
            GROUP BY s.owner_id
          ) td ON td.owner_id = u.id

ORDER BY total_deposits DESC;
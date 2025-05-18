This repo holds the four SQL answers I wrote for the hiring assessment
that dropped into my inbox. The files you'll find are: •
Assessment_Q1.sql -- who already owns both a funded savings plan and a
funded investment? • Assessment_Q2.sql -- how often do people move
money? (High ≥ 10 tx/month, Medium 3-9, Low ≤ 2) • Assessment_Q3.sql --
ping the ops team when an account has been stone-cold silent for over a
year. • Assessment_Q4.sql -- back-of-the-envelope Customer Lifetime
Value with a 0.1 % margin.

Read on if you want the nerdy back-story of each query and the potholes
I hit while writing them.

⸻

Q1 -- Cross-sell Candidates

What I did I join plans to deposits, count savings vs. investment plans
separately, then bring it all together with the customer table. A plan
is "funded" only if it's seen at least one deposit (confirmed_amount \>
0). Finally, I sum every deposit (kobo → naira) so we can sort by who's
worth calling first.

Challenges & fixes

• I first tried p.confirmed_amount (oops, column lives in
savings_savingsaccount). • My test DB is 5.7, so the original CTE
version blew up. Swapped CTEs for inline sub-queries.

⸻

Q2 -- Transaction Frequency

What I did • Count transactions per customer per month. • Average those
counts → "how many times do you move money in a typical month?" •
Bucket: High ≥ 10, Medium 3-9, Low ≤ 2. • Show bucket, number of people
inside, and bucket-level average.

Challenges & fixes • MySQL sorts text alphabetically; I forced the order
High→Medium→Low with FIELD().

⸻

Q3 -- Inactivity Alert

What I did Savings flows are owner-level, investments are plan-level and
split across deposits + withdrawals. I...  1. Grabbed the last savings
txn per owner. 2. UNION-ed deposits & withdrawals, then took the last
txn per investment plan. 3. Merged those two lists, filtered "older than
365 days," and added a DATEDIFF column.

Challenges & fixes • Savings have no plan_id, so I put NULL there and
tagged the row type = \'Savings\'. • Remembered to DROP temp tables so
Workbench doesn't complain on reruns.

⸻

Q4 -- Quick-n-Dirty CLV

What I did Tenure in months via TIMESTAMPDIFF. One inline sub-query (tx)
gets total transactions & volume. CLV formula straight from the prompt:

annual_tx_rate = total_tx / tenure_months \* 12 avg_profit_tx =
(avg_tx_value) \* 0.1 % estimated_clv = annual_tx_rate \* avg_profit_tx

Challenges & fixes • If tenure = 0 (signed up today) or no transactions,
division by zero lurks. Wrapped with NULLIF and default CLV to 0. • HR
asked me to shrink the query---ended up under 25 lines including
comments.

⸻

How to run these

mysql -u root -p USE your_database; SOURCE Assessment_Q1.sql; SOURCE
Assessment_Q2.sql; SOURCE Assessment_Q3.sql; SOURCE Assessment_Q4.sql;

Q2 and Q3 create temp tables but clean up after themselves; the database
remains completely unchanged post-execution.

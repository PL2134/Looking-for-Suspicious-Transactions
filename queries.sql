SELECT * FROM card_holder;
SELECT * FROM credit_card;
SELECT * FROM merchant_category;
SELECT * FROM merchant;
SELECT * FROM transaction;

-- Group the transactions of each cardholder
CREATE VIEW transaction_by_card_holder AS
SELECT ch.name, cc.card, t.date, t.amount, m.name AS merchant,
       mc.name AS category
FROM transaction AS t
JOIN credit_card AS cc ON cc.card = t.card
JOIN card_holder AS ch ON ch.id = cc.id_card_holder
JOIN merchant AS m ON m.id = t.id_merchant
JOIN merchant_category AS mc ON mc.id = m.id_merchant_category
ORDER BY ch.name;

SELECT *
FROM transaction_by_card_holder;

-- Count the transactions that are less than $2.00 per cardholder
CREATE VIEW num_transactions_under_2_dollars AS
SELECT ch.name, COUNT(*)
FROM transaction AS t
JOIN credit_card AS cc ON cc.card = t.card
JOIN card_holder AS ch ON ch.id = cc.id_card_holder
WHERE t.amount < 2
GROUP BY ch.name;

SELECT *
FROM num_transactions_under_2_dollars;

-- Is there any evidence to suggest that a credit card has been hacked?
-- Explain your rationale.
CREATE VIEW num_transactions_under_2_dollars_card AS
SELECT cc.card, COUNT(*)
FROM transaction AS t
JOIN credit_card AS cc ON cc.card = t.card
JOIN card_holder AS ch ON ch.id = cc.id_card_holder
WHERE t.amount < 2
GROUP BY cc.card;

SELECT *
FROM num_transactions_under_2_dollars_card;
-- No, there is not much evidence to suggest that a credit card has been hacked
-- As the numbers of transactions under 2 dollars on each card
-- are quite normally distributed.

-- The top 100 highest transactions made between 7:00 am and 9:00 am
CREATE VIEW one_hundred_highest_transactions_7_to_9_am AS
SELECT *
FROM transaction AS t
WHERE DATE_PART('hour', t.date)>=7
AND DATE_PART('hour', t.date)<=9
ORDER BY amount DESC
limit 100;

SELECT *
FROM one_hundred_highest_transactions_7_to_9_am;

-- The top 100 highest transactions made between 7:00 am and 9:00 am to minutes
CREATE VIEW one_hundred_highest_transactions_7_to_9_am_to_mintues AS
SELECT *
FROM transaction AS t
WHERE CAST(t.date as time) BETWEEN CAST('07:00:00' as time) AND CAST('09:00:00' as time)
ORDER BY amount DESC
limit 100;

SELECT *
FROM one_hundred_highest_transactions_7_to_9_am_to_mintues;

-- Potential anomalous transactions that could be fraudulent during 7 am to 9am
CREATE VIEW transactions_under_2_dollars_7_to_9_am AS
SELECT COUNT(*) AS num_transactions
FROM transaction AS t
WHERE CAST(t.date as time) BETWEEN CAST('07:00:00' as time) AND CAST('09:00:00' as time)
AND t.amount < 2;

SELECT *
FROM transactions_under_2_dollars_7_to_9_am;
-- 30 fraudulent transactions happened during 7 am to 9am
-- 15 fraudulent transactions per hour on average

-- The number of anomalous transactions happened during the rest of the day
CREATE VIEW transactions_under_2_dollars_outside_7_to_9_am AS
SELECT COUNT(*) AS num_transactions
FROM transaction AS t
WHERE CAST(t.date as time) NOT BETWEEN CAST('07:00:00' as time) AND CAST('09:00:00' as time)
AND t.amount < 2;

SELECT *
FROM transactions_under_2_dollars_outside_7_to_9_am;
-- 320 fraudulent transactions happened outside of 7 am to 9am
-- 14.55 fraudulent transactions per hour on average
-- To conclude, the number of fraudulent transactions 
-- are not significantly higher during 7 am to 9 am
-- comparing to the rest of the day

-- The top 5 merchants prone to being hacked using small transactions
CREATE VIEW top_merchants_under_2_dollars AS
SELECT m.id, m.name AS merchant_name, COUNT(*) AS num_transactions_merchants
FROM transaction AS t
JOIN merchant AS m ON t.id_merchant = m.id
WHERE t.amount < 2
GROUP BY t.id_merchant, m.id, merchant_name
ORDER BY num_transactions_merchants DESC
LIMIT 5;

SELECT * FROM top_merchants_under_2_dollars;




--Capstone: Funnels with Warby Parker

--1. The users' responses are stored in a table called survey
SELECT *
FROM survey
LIMIT 10;


--2. Create a quiz funnel using the GROUP BY command.
SELECT question, COUNT(*)
FROM survey
GROUP BY 1;

--3. Calculate the percentage of users who answer each question
SELECT question,
        COUNT(*) AS 'total_responses',
        ROUND(((1.0 * COUNT(*) / 500 ) * 100), 1) AS 'perc_of_total'
FROM survey
GROUP BY 1;

--5. We'd like to create a new table
SELECT q.user_id AS 'user_id',
			CASE
                WHEN h.user_id IS NULL THEN 'False'
                ELSE 'True' END AS 'is_home_try_on',
                h.number_of_pairs AS 'number_of_pairs',
            CASE
              	WHEN p.user_id IS NULL THEN 'False'
                ELSE 'True' END AS 'is_purchase'
FROM quiz AS q
LEFT JOIN home_try_on AS h
ON q.user_id = h.user_id
LEFT JOIN purchase AS p
ON q.user_id = p.user_id
LIMIT 10;

--6. Once we have the data in this format, we can analyze it in several ways
-- We can calculate overall conversion rates by aggregating across all rows.
-- We can compare conversion from quiz→home_try_on and home_try_on→purchase.
WITH funnels AS (SELECT q.user_id AS 'user_id',
			CASE
                WHEN h.user_id IS NULL THEN 'False'
                ELSE 'True' END AS 'is_home_try_on',
                h.number_of_pairs AS 'number_of_pairs',
            CASE
              	WHEN p.user_id IS NULL THEN 'False'
                ELSE 'True' END AS 'is_purchase'
FROM quiz AS q
LEFT JOIN home_try_on AS h
ON q.user_id = h.user_id
LEFT JOIN purchase AS p
ON q.user_id = p.user_id),

conversion AS (SELECT COUNT(user_id) AS 'count_quiz',
				SUM(CASE WHEN is_home_try_on = 'True' THEN 1
           			ELSE NULL END) AS 'count_home_try_on',
                SUM(CASE WHEN is_purchase = 'True' THEN 1
           			ELSE NULL END) AS 'count_purchase'
FROM funnels)

SELECT count_quiz,
		count_home_try_on,
        count_purchase,
        (1.0 * count_home_try_on / count_quiz) * 100 AS '%_quiz_to_try_on',
        (1.0 * count_purchase / count_home_try_on) * 100 AS '%_try_on_to_purchase'
FROM conversion;

-- We can calculate the difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5.
WITH home_pairs AS (SELECT number_of_pairs,
                    COUNT(*) AS home_try_on
FROM home_try_on
GROUP BY 1),

purchase_pairs AS (SELECT h.number_of_pairs AS number_of_pairs,
                   COUNT(*) as purchase
FROM home_try_on AS h
JOIN purchase AS p
ON h.user_id = p.user_id
GROUP BY 1)


SELECT h.number_of_pairs AS number_of_pairs,
			home_try_on,
            purchase,
            ROUND((1.0 * purchase / home_try_on), 4) * 100 AS '%_purchase_rate'
FROM home_pairs AS h
JOIN purchase_pairs AS p
ON h.number_of_pairs = p.number_of_pairs;

--The most common results of the style quiz
WITH style AS (SELECT style AS response,
               				COUNT(*),
               				'style' AS 'question'
                FROM quiz
                GROUP BY 1
                ORDER BY 2 DESC),
      fit AS (SELECT fit AS response,
               				COUNT(*),
               				'fit' AS 'question'
                FROM quiz
                GROUP BY 1
                ORDER BY 2 DESC),
      shape AS (SELECT shape AS response,
               				COUNT(*),
               				'shape' AS 'question'
                FROM quiz
                GROUP BY 1
                ORDER BY 2 DESC),
      color AS (SELECT color AS response,
               				COUNT(*),
               				'color' AS 'question'
                FROM quiz
                GROUP BY 1
                ORDER BY 2 DESC)


SELECT *
FROM style
UNION ALL
SELECT *
FROM fit
UNION ALL
SELECT *
FROM shape
UNION ALL
SELECT *
FROM color;

-- The most common types of purchase made
SELECT product_id, style, model_name, color, COUNT(*) AS 'total'
FROM purchase
GROUP BY 1
ORDER BY total DESC;

--test
SELECT COUNT(user_id),
				SUM(CASE
           			WHEN is_home_try_on = 'True' THEN 1
           			ELSE NULL END) AS 'count_is_home_try_on'
FROM funnels;

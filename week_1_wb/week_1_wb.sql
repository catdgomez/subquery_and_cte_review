
-- ## Week 1, Part 1: Subquery and CTE Review

-- 1. Find all patients whose age is greater than the average age of all patients. Hint: there is a year_of_birth column in the person table.



-- APPROACH 1
	SELECT
		p.person_id,
		p.year_of_birth,
		(EXTRACT(YEAR FROM CURRENT_DATE) - p.year_of_birth) AS current_age
	FROM person AS p
	WHERE (EXTRACT(YEAR FROM CURRENT_DATE) - p.year_of_birth) > (
			SELECT
				AVG(EXTRACT(YEAR FROM CURRENT_DATE) - p.year_of_birth) AS avg_age
				FROM person AS p
		);

-- **APPROACH 2**
SELECT
	person_id,
	year_of_birth,
	AGE(CURRENT_DATE, MAKE_DATE(year_of_birth, month_of_birth, day_of_birth)) AS age
FROM person
WHERE year_of_birth < (
						SELECT AVG(year_of_birth)
						FROM person
					   );

-- APPROACH 3

	WITH patient_age AS (
	SELECT
		person_id,
		year_of_birth,
		AGE(CURRENT_DATE, MAKE_DATE(year_of_birth, month_of_birth, day_of_birth)) AS age
	FROM person
	)
	
	SELECT
		*
	FROM patient_age
	WHERE age > 
				(SELECT AVG(age) FROM patient_age);
			
-- APPROACH 4
	SELECT 
		DISTINCT person_id, 
		(2026 - year_of_birth) AS age
	FROM person
	GROUP BY person_id
	HAVING (2026 - year_of_birth) > (SELECT AVG(2026 - year_of_birth) FROM person);

-- 2. Find all patients with the condition type 2 diabetes mellitus. This condition is encoded using condition_concept_id = 201826 in the condition_occurrence table. Return the person_id and year_of_birth for these patients. Do this in two ways. First, join the person and condition_occurrence tables. Warning: make sure that you return each person_id only once. Then use a subquery with EXISTS. Which is faster?


-- A)
SELECT
	DISTINCT
		co.person_id,
		p.year_of_birth
FROM condition_occurrence AS co
INNER JOIN person AS P
ON co.person_id = p.person_id
WHERE condition_concept_id = 201826;

-- B)

-- Returns in 11 seconds

SELECT 
	DISTINCT
		p.person_id,
		p.year_of_birth
FROM person AS p
WHERE EXISTS (
	SELECT 
		co.person_id
	FROM condition_occurrence AS co
	WHERE co.person_id = p.person_id 
		AND condition_concept_id = 201826
);
-- Returns in 6 seconds

-- 3. For each patient in the person table, find the number of different condition_concept_id values that show up in the condition_occurrence table. Do this in two ways. First, use a join to connect the two tables. Then use a subquery in SELECT. The subquery in SELECT will have to be a [correlated subquery](https://www.geeksforgeeks.org/sql/sql-correlated-subqueries/). Note: make sure that you end up with 100000 rows in your result. Which version is faster?


-- A) Time: 00:00:02.528
SELECT
		p.person_id,
		COUNT(co.condition_concept_id)
FROM person AS p
LEFT JOIN condition_occurrence AS co
ON p.person_id = co.person_id
GROUP BY p.person_id

-- B) Time: 00:00:22.408

SELECT
	p.person_id,
(
	SELECT 
		COUNT(co.condition_concept_id)
	FROM condition_occurrence AS co
	WHERE co.person_id = p.person_id
	GROUP BY co.person_id
 ) AS condition_count
FROM person AS p

-- 4. For this question, use the drug_exposure table. For each drug concept, find the largest number of events for a single person associated with that drug. Your output should show that, for example, drug_concept_id 1301125 (epoetin alfa) had a patient with 332 events. 


SELECT
	drug_concept_id,
	person_id,
	COUNT(DISTINCT drug_exposure_id) AS events
FROM drug_exposure
GROUP BY drug_concept_id, person_id
ORDER BY events DESC
LIMIT 1;

-- 5. Write a query to find the number of different drug concepts for each person. Then use this as a CTE to find all patients with more than 10 different drugs.

WITH drug_exposure AS (
SELECT
	 person_id,
	COUNT(DISTINCT drug_concept_id) AS total_drugs
FROM drug_exposure
GROUP BY person_id
)

SELECT 
	person_id,
	total_drugs AS more_than_10_total_drugs
FROM drug_exposure
WHERE total_drugs > 10;


-- 6. Using the visit_occurrence table, find all patients with a higher number of visits than the average for their gender. Hint: write one CTE to find the total number of visits per patient. Then write a second CTE to find the average per gender.

WITH patient_visits AS (
SELECT
		vo.person_id,
		COUNT(vo.visit_occurrence_id) AS total_visits
FROM visit_occurrence AS vo
GROUP BY vo.person_id
),

visits_per_gender AS (
SELECT
	p.gender_concept_id,
	AVG(pv.total_visits) AS avg_visits_per_gender
FROM person AS p
INNER JOIN patient_visits AS pv
ON p.person_id = pv.person_id
GROUP BY p.gender_concept_id
)

SELECT
	p.person_id,
	pv.total_visits
FROM person AS p
INNER JOIN patient_visits AS pv
ON p.person_id = pv.person_id
INNER JOIN visits_per_gender AS vpg
ON p.gender_concept_id = vpg.gender_concept_id
WHERE total_visits > avg_visits_per_gender


-- 7. For each patient, find the most recent visit.

--  APPROACH 1
SELECT 
	vo.person_id,
	MAX(vo.visit_start_date) AS latest_date
FROM visit_occurrence AS vo
GROUP BY vo.person_id

--  APPROACH 2

WITH most_recent AS (
SELECT 
	vo.person_id,
	MAX(vo.visit_start_date) AS latest_date
FROM visit_occurrence AS vo
GROUP BY vo.person_id
)

SELECT
	v.person_id, 
	v.visit_occurrence_id, 
	v.visit_start_date
FROM visit_occurrence AS v
INNER JOIN most_recent AS mr
	ON v.person_id = mr.person_id
	AND v.visit_start_date = mr.latest_date

-- 8. Find patients who had a drug exposure before their first recorded condition diagnosis. Condition diagnoses can be found in the condition_occurrence table.

--  APPROACH 1
WITH first_diagnosis AS (
SELECT 
	co.person_id,
	MIN(co.condition_start_datetime) AS condition_start
FROM condition_occurrence AS co
GROUP BY co.person_id
)

SELECT 
	DISTINCT de.person_id,
	condition_start,
	de.drug_exposure_start_date
FROM drug_exposure AS de
INNER JOIN first_diagnosis AS fd
ON de.person_id = fd.person_id
WHERE de.drug_exposure_start_date < fd.condition_start

-- APPROACH 2
	SELECT
	de.person_id,
	MIN(co.condition_start_datetime) AS condition_start_date,
	MIN(de.drug_exposure_start_date) AS drug_exposure_start_date
FROM drug_exposure AS de
INNER JOIN condition_occurrence AS co
ON de.person_id = co.person_id
GROUP BY de.person_id
HAVING MIN(co.condition_start_datetime) > MIN(de.drug_exposure_start_date)
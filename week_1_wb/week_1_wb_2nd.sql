Week 1, Part 1: Subquery and CTE Review
-- Find all patients whose age is greater than the average age of all patients. Hint: there is a year_of_birth column in the person table.

-- Find all patients with the condition type 2 diabetes mellitus. This condition is encoded using condition_concept_id = 201826 in the condition_occurrence table. Return the person_id and year_of_birth for these patients. Do this in two ways. First, join the person and condition_occurrence tables. Warning: make sure that you return each person_id only once. Then use a subquery with EXISTS. Which is faster?

-- For each patient in the person table, find the number of different condition_concept_id values that show up in the condition_occurrence table. Do this in two ways. First, use a join to connect the two tables. Then use a subquery in SELECT. The subquery in SELECT will have to be a correlated subquery. Note: make sure that you end up with 100000 rows in your result. Which version is faster?

-- For this question, use the drug_exposure table. For each drug concept, find the largest number of events for a single person associated with that drug. Your output should show that, for example, drug_concept_id 1301125 (epoetin alfa) had a patient with 332 events.

-- 5) Write a query to find the number of different drug concepts for each person. Then use this as a CTE to find all patients with more than 10 different drugs.

WITH drugs_assigned AS (
SELECT
	p.person_id,
	COUNT(DISTINCT de.drug_concept_id) AS distinct_drug_types
FROM person p
INNER JOIN drug_exposure de
ON p.person_id = de.person_id
GROUP BY p.person_id
)

SELECT 
	*
FROM person p
WHERE p.person_id IN (
						SELECT
							person_id
						FROM drugs_assigned da
						WHERE distinct_drug_types > 10
);

Query complete 00:00:28.949
Total rows: 64209


-- 6) Using the visit_occurrence table, find all patients with a higher number of visits than the average for their gender. Hint: write one CTE to find the total number of visits per patient. Then write a second CTE to find the average per gender.

WITH number_of_patient_visits AS (
SELECT
	vo.person_id,
	COUNT(vo.visit_occurrence_id) AS visit_amount
FROM visit_occurrence vo
GROUP BY vo.person_id
),

average_per_gender AS (
SELECT
	p.gender_source_value AS gender,
	AVG(visit_amount) AS avg_per_gender
FROM person p
INNER JOIN number_of_patient_visits npv
ON p.person_id = npv.person_id
GROUP BY p.gender_source_value
)

SELECT
	p.person_id
FROM person p
INNER JOIN number_of_patient_visits npv
ON p.person_id = npv.person_id
INNER JOIN average_per_gender apg
ON p.gender_source_value = apg.gender
WHERE npv.visit_amount > apg.avg_per_gender


-- 7) For each patient, find the most recent visit.

WITH most_recent_visit AS (
	SELECT
		vo.person_id,
		MAX(visit_end_date) AS most_recent_date
	FROM visit_occurrence vo
	GROUP BY vo.person_id
)


SELECT
	vo.visit_occurrence_id,
	vo.person_id,
	vo.visit_concept_id,
	mrv.most_recent_date
FROM visit_occurrence vo
INNER JOIN most_recent_visit mrv
ON vo.person_id = mrv.person_id
AND vo.visit_end_date = mrv.most_recent_date


-- Find patients who had a drug exposure before their first recorded condition diagnosis. Condition diagnoses can be found in the condition_occurrence table.
-- Week 1, Part 1: Subquery and CTE Review

-- 4. For this question, use the drug_exposure table. 
-- For each drug concept, 
-- find the largest number of events 
-- for a single person 
-- associated with that drug. 
-- Your output should show that, for example, drug_concept_id 
-- 1301125 (epoetin alfa) had a patient with 332 events.

WITH drug_count_per_person AS (
	SELECT COUNT(drug_exposure_id) AS drug_event, drug_concept_id, person_id
	FROM drug_exposure
	GROUP BY drug_concept_id, person_id
)
SELECT MAX(drug_event) AS max_drug_event, drug_concept_id
FROM drug_count_per_person
GROUP BY drug_concept_id
ORDER BY max_drug_event DESC
LIMIT 1;

-- 8. Find patients who had a drug exposure before their first recorded 
-- condition diagnosis. Condition diagnoses can be found in the 
-- condition_occurrence table.




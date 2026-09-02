Week 1, Part 1: Subquery and CTE Review
Find all patients whose age is greater than the average age of all patients. Hint: there is a year_of_birth column in the person table.

Find all patients with the condition type 2 diabetes mellitus. This condition is encoded using condition_concept_id = 201826 in the condition_occurrence table. Return the person_id and year_of_birth for these patients. Do this in two ways. First, join the person and condition_occurrence tables. Warning: make sure that you return each person_id only once. Then use a subquery with EXISTS. Which is faster?

For each patient in the person table, find the number of different condition_concept_id values that show up in the condition_occurrence table. Do this in two ways. First, use a join to connect the two tables. Then use a subquery in SELECT. The subquery in SELECT will have to be a correlated subquery. Note: make sure that you end up with 100000 rows in your result. Which version is faster?

For this question, use the drug_exposure table. For each drug concept, find the largest number of events for a single person associated with that drug. Your output should show that, for example, drug_concept_id 1301125 (epoetin alfa) had a patient with 332 events.

Write a query to find the number of different drug concepts for each person. Then use this as a CTE to find all patients with more than 10 different drugs.

Using the visit_occurrence table, find all patients with a higher number of visits than the average for their gender. Hint: write one CTE to find the total number of visits per patient. Then write a second CTE to find the average per gender.

For each patient, find the most recent visit.

Find patients who had a drug exposure before their first recorded condition diagnosis. Condition diagnoses can be found in the condition_occurrence table.

/*
Question: What are the most optimal skills to learn (it's in high-demand and a paying skill)
- idenitfy skills in high demand and associated with high average salaries for Data Analyst roles
- concentrates on remote positions with specified salaries
- this targets skills that offer job security

*/

WITH skills_demand as (

    SELECT 

    skills_dim.skills,
    skills_dim.skill_id,
    count(skills_job_dim.job_id) as demand_count

FROM job_postings_fact

INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
  -- AND job_work_from_home = TRUE
    AND salary_year_avg is NOT NULL
   
GROUP BY
 skills_dim.skills,
    skills_dim.skill_id

HAVING
    count(skills_job_dim.job_id) > 10
-- ORDER BY
--      demand_count DESC

),

average_salary as (

    SELECT 

    skills_dim.skills,
    skills_dim.skill_id,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) as avg_salary

FROM job_postings_fact

INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
  -- AND job_work_from_home = TRUE
  AND salary_year_avg is NOT NULL
GROUP BY
 skills_dim.skills,
    skills_dim.skill_id
-- ORDER BY
--      avg_salary DESC
-- removing the order by to speed up
)

SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    skills_demand.demand_count,
    average_salary.avg_salary

FROM
    skills_demand

INNER JOIN average_salary ON skills_demand.skill_id = average_salary.skill_id

WHERE demand_count > 10

ORDER BY demand_count DESC,
        avg_salary DESC
        
limit 50;
/*
Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from first query
- Add the specific skill required for those roles


start by removing unnecessary columns.
make the result of query 1 a CTE
inner join to choose only skills that match salaries
*/



WITH top_paying_jobs AS (
    SELECT 
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM job_postings_fact
    LEFT JOIN company_dim
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.job_id,
    top_paying_jobs.job_title,
    top_paying_jobs.company_name,
    top_paying_jobs.salary_year_avg,
    STRING_AGG(skills_dim.skills, ', ' ORDER BY skills_dim.skills) AS skills
FROM top_paying_jobs
INNER JOIN skills_job_dim 
    ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
GROUP BY 
    top_paying_jobs.job_id,
    top_paying_jobs.job_title,
    top_paying_jobs.company_name,
    top_paying_jobs.salary_year_avg
ORDER BY top_paying_jobs.salary_year_avg DESC;




/*


The query above performs optimally, but the query below is an alternative.
Using a second CTE for the skills. But the query below takes longer to run.
Why? it's aggregating for the entire skills_dim table and not top 10.

WITH top_paying_jobs AS (
    SELECT 
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM job_postings_fact
    LEFT JOIN company_dim
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
),

job_skills AS (
    SELECT 
        skills_job_dim.job_id,
        STRING_AGG(skills_dim.skills, ', ' ORDER BY skills_dim.skills) AS skills
    FROM skills_job_dim
    INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
    GROUP BY skills_job_dim.job_id
)

SELECT 
    top_paying_jobs.*,
    job_skills.skills
FROM top_paying_jobs
INNER JOIN job_skills
    ON top_paying_jobs.job_id = job_skills.job_id
ORDER BY top_paying_jobs.salary_year_avg DESC;


What's the fix here?

job_skills AS (
    SELECT 
        skills_job_dim.job_id,
        STRING_AGG(skills_dim.skills, ', ' ORDER BY skills_dim.skills) AS skills
    FROM skills_job_dim
    INNER JOIN skills_dim
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE skills_job_dim.job_id IN (SELECT job_id FROM top_paying_jobs)
    GROUP BY skills_job_dim.job_id
)


Aggregating only for select job_ids

*/
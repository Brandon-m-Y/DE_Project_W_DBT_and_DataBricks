WITH source AS (
    SELECT *
    FROM {{ source('jobs', 'raw_job_postings') }}
    WHERE error IS NOT TRUE
      -- ~0.9% of real postings have no job_id; they can't join to skills
      -- or be tracked across scrape days, so drop them here.
      AND job_id IS NOT NULL
),

cleaned AS (
SELECT
    job_id,
    job_title,
    TRIM(company_name) AS company_name,
    job_location,
    REGEXP_REPLACE(job_via, '^via ', '') AS job_via,
    job_posted_at,
    job_salary,
    job_schedule_type,
    job_work_from_home,
    job_detected_extensions_raw,
    search_time,
    search_date,
    search_term,
    search_location

FROM source
)

SELECT *
FROM cleaned;
   

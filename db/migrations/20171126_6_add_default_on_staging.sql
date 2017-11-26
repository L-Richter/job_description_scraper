BEGIN;

ALTER TABLE job_descriptions_staging
ALTER company SET DEFAULT 'na',
ALTER company_name SET DEFAULT 'na',
ALTER job_title SET DEFAULT 'No Title',
ALTER location SET DEFAULT 'unknown',
ALTER department SET DEFAULT 'unknown';

UPDATE job_descriptions_staging
SET company = COALESCE(company, 'na'),
    company_name = COALESCE(company_name, 'na'),
    job_title = COALESCE(job_title, 'No Title'),
    location = COALESCE(location, 'unknown'),
    department = COALESCE(department, 'unknown');
   
ALTER TABLE job_descriptions_staging
ALTER COLUMN company SET NOT NULL,
ALTER COLUMN company_name SET NOT NULL,
ALTER COLUMN natural_id SET NOT NULL,
ALTER COLUMN job_title SET NOT NULL,
ALTER COLUMN job_description_hash SET NOT NULL,
ALTER COLUMN location SET NOT NULL,
ALTER COLUMN department SET NOT NULL;

COMMIT;

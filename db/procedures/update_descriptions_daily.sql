CREATE OR REPLACE FUNCTION update_descriptions_daily_fact()
    RETURNS void AS $$
    DECLARE
        max_intervall INTEGER := 10000;
        last_pulled BIGINT := (SELECT COALESCE(MAX(id), 0) from descriptions_daily_fact);
        last_to_pull BIGINT := last_pulled + max_intervall;
        companies_before_update INT := (SELECT count(*) FROM company_dim);
        job_details_before_update INT := (SELECT count(*) FROM job_details_dim);
    BEGIN
    --- update company_dim ---
        INSERT INTO company_dim (company_slug, company_name)
           (SELECT DISTINCT jds.company AS company_slug,
                            jds.company_name
            FROM job_descriptions_staging jds
            LEFT JOIN company_dim cd
                ON(cd.company_name = jds.company_name
                   AND cd.company_slug = jds.company)
            WHERE version = 1
              AND id > last_pulled
              AND id <= last_to_pull
              AND cd.company_sk is NULL);

        INSERT INTO _log (name, log_comment)
            SELECT 'update_descriptions_daily' as name,
                   CONCAT(count(*) - companies_before_update,
                          ' companies added') as log_comment
            FROM company_dim;

     --- update job_details_dim ---
        INSERT INTO job_details_dim (job_title, job_description_hash, location, department)
           (SELECT DISTINCT jds.job_title,
                            jds.job_description_hash,
                            jds.location,
                            jds.department
            FROM job_descriptions_staging jds
            LEFT JOIN job_details_dim jdd
                ON(jdd.job_title = jds.job_title
                   AND jdd.job_description_hash = jds.job_description_hash
                   AND jdd.location = jds.location
                   AND jdd.department = jds.department)
            WHERE version = 1
              AND id > last_pulled
              AND id <= last_to_pull
              AND jdd.job_details_sk is NULL);

        INSERT INTO _log (name, log_comment)
            SELECT 'update_descriptions_daily' as name,
                   CONCAT(count(*) - job_details_before_update,
                          ' job details added') as log_comment
            FROM job_details_dim;
            
       --- update job_description_daily_fact ---
       INSERT INTO descriptions_daily_fact (date_sk,
                                            company_sk,
                                            natural_id,
                                            job_details_sk,
                                            storage_key)
           SELECT DISTINCT trigger_date as date_sk,
                           company_sk,
                           natural_id,
                           job_details_sk,
                           storage_key
           FROM job_descriptions_staging jds
           JOIN company_dim cd
               ON(cd.company_name = jds.company_name
                  AND cd.company_slug = jds.company)
           JOIN job_details_dim jdd
               ON(jdd.job_title = jds.job_title
                  AND jdd.job_description_hash = jds.job_description_hash
                  AND jdd.location = jds.location
                  AND jdd.department = jds.department)
           WHERE version = 1
              AND id > last_pulled
              AND id <= last_to_pull;

        INSERT INTO _log (name, log_comment)
            SELECT 'update_descriptions_daily' as name,
                   CONCAT('Old max id: ',
                          last_pulled,
                          'New max id: ',
                          COALESCE(max(id), 0)) as log_comment
            FROM descriptions_daily_fact;
    END;
    $$ LANGUAGE plpgsql;


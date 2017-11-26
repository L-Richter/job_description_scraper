BEGIN;

DROP TABLE IF EXISTS descriptions_daily_fact;

CREATE TABLE IF NOT EXISTS descriptions_daily_fact (
    id                  BIGINT PRIMARY KEY,
    date_sk             INT NOT NULL,
    company_sk          INT NOT NULL,
    natural_id          UUID NOT NULL,
    job_details_sk      INT NOT NULL,
    storage_key		    VARCHAR(128)
);

ALTER TABLE descriptions_daily_fact 
ADD CONSTRAINT ddf_date_sk_fkey
FOREIGN KEY (date_sk) REFERENCES date_dim (date_sk);

ALTER TABLE descriptions_daily_fact 
ADD CONSTRAINT ddf_company_sk_fkey
FOREIGN KEY (company_sk) REFERENCES company_dim (company_sk);

ALTER TABLE descriptions_daily_fact 
ADD CONSTRAINT ddf_job_details_sk_fkey
FOREIGN KEY (job_details_sk) REFERENCES job_details_dim (job_details_sk);

CREATE INDEX descriptions_daily_fact_date_company_idx
  ON descriptions_daily_fact(date_sk, company_sk);
  
CREATE INDEX descriptions_daily_fact_natid_idx
  ON descriptions_daily_fact(natural_id);

COMMIT;


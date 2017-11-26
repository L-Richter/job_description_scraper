BEGIN;

DROP TABLE if exists job_details_dim;

CREATE TABLE IF NOT EXISTS job_details_dim (
    job_details_sk          SERIAL PRIMARY KEY,
	job_title		        VARCHAR(128) NOT NULL DEFAULT 'No Title',
	job_description_hash	UUID NOT NULL,
	location		        VARCHAR(128) NOT NULL DEFAULT 'unknown',
	department		        VARCHAR(128) NOT NULL DEFAULT 'unknown',
    CONSTRAINT job_details_unique UNIQUE(job_title,
                                         job_description_hash,
                                         location,
                                         department)
);

COMMIT;


CREATE TABLE IF NOT EXISTS job_descriptions_staging (
	id			        BIGSERIAL PRIMARY KEY,
	created_at 		    TIMESTAMP NOT NULL,
	trigger_date	    INT,
	company			    VARCHAR(32),
	company_name		VARCHAR(128),
	version 		    SMALLINT NOT NULL,
	storage_key		    VARCHAR(128),
	natural_id		    UUID,
	job_title		    VARCHAR(128),
	job_description_hash	UUID,
	location		    VARCHAR(128),
	department		    VARCHAR(128)
)


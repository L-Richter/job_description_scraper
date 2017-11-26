BEGIN;

DROP TABLE if exists company_dim;

CREATE TABLE IF NOT EXISTS company_dim (
    company_sk          SERIAL PRIMARY KEY,
    company_slug        VARCHAR(32) NOT NULL,
    company_name        VARCHAR(128),
    CONSTRAINT company UNIQUE(company_slug, company_name)
);

COMMIT;


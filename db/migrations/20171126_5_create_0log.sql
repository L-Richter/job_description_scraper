BEGIN;

DROP TABLE if exists _log;

CREATE TABLE IF NOT EXISTS _log (
    id                      BIGSERIAL PRIMARY KEY,
    created_at              TIMESTAMP DEFAULT NOW(),
    name                    VARCHAR(128),
    log_comment             TEXT
);

COMMIT;


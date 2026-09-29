-- Biblioteca de lo Sagrado / PostgreSQL schema v1.1
-- Integrity patch: provenance FK and missing work-status index.

BEGIN;

ALTER TABLE place_names
    ADD CONSTRAINT place_names_source_fk
    FOREIGN KEY (source_id) REFERENCES sources(id) ON DELETE RESTRICT;

CREATE INDEX works_status_idx ON works(status);

COMMIT;

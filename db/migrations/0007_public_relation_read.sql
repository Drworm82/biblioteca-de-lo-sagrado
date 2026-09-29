BEGIN;

CREATE POLICY public_read_relations
    ON relations
    FOR SELECT
    USING (true);

CREATE POLICY public_read_relation_sources
    ON relation_sources
    FOR SELECT
    USING (true);

CREATE POLICY public_read_relation_evidence
    ON relation_evidence
    FOR SELECT
    USING (true);

COMMIT;

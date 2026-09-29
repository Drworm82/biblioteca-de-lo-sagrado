BEGIN;

GRANT SELECT ON evidence, historical_events TO anon, authenticated;

GRANT SELECT ON relations, relation_sources, relation_evidence TO anon, authenticated;

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

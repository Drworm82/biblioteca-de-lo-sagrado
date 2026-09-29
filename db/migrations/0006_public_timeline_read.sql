-- Biblioteca de lo Sagrado / Migration 0006
-- Public read access for timeline data used by the public application.

BEGIN;

CREATE POLICY public_read_evidence
    ON evidence
    FOR SELECT
    USING (true);

CREATE POLICY public_read_historical_events
    ON historical_events
    FOR SELECT
    USING (true);

COMMIT;

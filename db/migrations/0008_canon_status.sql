BEGIN;

CREATE TABLE canon_statuses(
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    work_id uuid NOT NULL REFERENCES works(id) ON DELETE RESTRICT,
    tradition_id uuid REFERENCES traditions(id) ON DELETE RESTRICT,
    community text,
    period_id uuid REFERENCES periods(id) ON DELETE RESTRICT,
    status text NOT NULL,
    source_id uuid REFERENCES sources(id) ON DELETE RESTRICT,
    source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK(status IN ('canonical','accepted','disputed','rejected','used_liturgically','read_as_edifying','non_canonical','unknown'))
);

CREATE INDEX canon_statuses_work_idx ON canon_statuses(work_id);
CREATE INDEX canon_statuses_tradition_idx ON canon_statuses(tradition_id);
CREATE INDEX canon_statuses_period_idx ON canon_statuses(period_id);

GRANT SELECT ON canon_statuses TO anon, authenticated;

CREATE POLICY public_read_canon_statuses
    ON canon_statuses
    FOR SELECT
    USING (true);

COMMIT;
-- Biblioteca de lo Sagrado / Migration 0005
-- Historical events are first-class, entity-backed timeline subjects.

BEGIN;

CREATE TABLE historical_events(
    id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
    title text NOT NULL,
    event_type text NOT NULL,
    description text NOT NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX historical_events_type_idx
    ON historical_events(event_type);

CREATE TABLE historical_event_sources(
    event_id uuid NOT NULL REFERENCES historical_events(id) ON DELETE RESTRICT,
    source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
    source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
    UNIQUE(event_id, source_id, source_location_id)
);

COMMIT;

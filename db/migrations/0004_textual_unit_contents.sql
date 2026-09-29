-- Biblioteca de lo Sagrado
-- Migration 0004: textual unit contents for the reader layer.

BEGIN;

CREATE TABLE textual_unit_contents (
    id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
    textual_unit_id uuid NOT NULL REFERENCES textual_units(id) ON DELETE RESTRICT,
    representation_type text NOT NULL,
    text_content text NOT NULL,
    normalized_text text,
    source_id uuid REFERENCES sources(id) ON DELETE RESTRICT,
    source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK (representation_type IN (
        'original',
        'transliteration',
        'close_translation',
        'readable_translation',
        'critical_text'
    )),
    UNIQUE(textual_unit_id, representation_type)
);

CREATE INDEX textual_unit_contents_unit_idx
    ON textual_unit_contents(textual_unit_id);

CREATE INDEX textual_unit_contents_source_idx
    ON textual_unit_contents(source_id);

COMMIT;

-- Biblioteca de lo Sagrado
-- Migration 0003: textual variants, dating basis, and editorial integrity.

BEGIN;

-- Explicit convention for historical year values.
-- astronomical_year: 1 BCE = 0, 2 BCE = -1, etc.
ALTER TABLE periods
    ADD COLUMN chronology_basis text NOT NULL DEFAULT 'astronomical_year',
    ADD CONSTRAINT periods_chronology_basis_ck
    CHECK (chronology_basis IN ('astronomical_year', 'relative', 'unknown'));

ALTER TABLE dating_assertions
    ADD COLUMN chronology_basis text NOT NULL DEFAULT 'astronomical_year',
    ADD CONSTRAINT dating_assertions_chronology_basis_ck
    CHECK (chronology_basis IN ('astronomical_year', 'relative', 'unknown'));

ALTER TABLE textual_units
    ADD CONSTRAINT textual_units_id_witness_uq
    UNIQUE(id, witness_id);

CREATE TABLE textual_variants (
    id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
    textual_unit_id uuid NOT NULL REFERENCES textual_units(id) ON DELETE RESTRICT,
    variant_type text NOT NULL,
    description text,
    status text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(id, textual_unit_id)
);

CREATE INDEX textual_variants_unit_idx
    ON textual_variants(textual_unit_id);

CREATE TABLE textual_variant_readings (
    id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
    variant_id uuid NOT NULL REFERENCES textual_variants(id) ON DELETE RESTRICT,
    witness_id uuid NOT NULL REFERENCES textual_witnesses(id) ON DELETE RESTRICT,
    textual_unit_id uuid NOT NULL REFERENCES textual_units(id) ON DELETE RESTRICT,
    reading_text text NOT NULL,
    normalized_text text,
    language_id uuid REFERENCES languages(id) ON DELETE RESTRICT,
    notes text,
    UNIQUE(variant_id, witness_id, textual_unit_id),
    FOREIGN KEY(textual_unit_id, witness_id)
        REFERENCES textual_units(id, witness_id)
        ON DELETE RESTRICT
);

CREATE INDEX textual_variant_readings_variant_idx
    ON textual_variant_readings(variant_id);

CREATE INDEX textual_variant_readings_witness_idx
    ON textual_variant_readings(witness_id);

-- A variant is anchored to one textual unit, but its readings may come from
-- corresponding units in other witnesses. Those witnesses must belong to the
-- same work as the variant's anchor witness.
CREATE OR REPLACE FUNCTION validate_textual_variant_reading_context()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    variant_work_id uuid;
    reading_work_id uuid;
BEGIN
    SELECT tw.work_id
      INTO variant_work_id
      FROM textual_variants tv
      JOIN textual_units tu ON tu.id = tv.textual_unit_id
      JOIN textual_witnesses tw ON tw.id = tu.witness_id
     WHERE tv.id = NEW.variant_id;

    SELECT tw.work_id
      INTO reading_work_id
      FROM textual_witnesses tw
     WHERE tw.id = NEW.witness_id;

    IF variant_work_id IS DISTINCT FROM reading_work_id THEN
        RAISE EXCEPTION
            'Textual variant reading witness must belong to the same work as the variant anchor';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER textual_variant_reading_context_trg
BEFORE INSERT OR UPDATE OF variant_id, witness_id, textual_unit_id
ON textual_variant_readings
FOR EACH ROW
EXECUTE FUNCTION validate_textual_variant_reading_context();

CREATE TABLE textual_variant_sources (
    variant_id uuid NOT NULL REFERENCES textual_variants(id) ON DELETE RESTRICT,
    source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
    source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
    UNIQUE(variant_id, source_id, source_location_id)
);

CREATE TABLE textual_variant_reading_sources (
    reading_id uuid NOT NULL REFERENCES textual_variant_readings(id) ON DELETE RESTRICT,
    source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
    source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
    UNIQUE(reading_id, source_id, source_location_id)
);

-- 0001 already established UNIQUE(entity_id, id), which is required
-- for this composite foreign key. Only add the cross-row integrity rule.
ALTER TABLE revisions
    ADD CONSTRAINT revisions_previous_same_entity_fk
    FOREIGN KEY(entity_id, previous_revision_id)
    REFERENCES revisions(entity_id, id)
    ON DELETE RESTRICT;

COMMIT;

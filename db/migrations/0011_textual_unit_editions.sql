-- Biblioteca de lo Sagrado
-- Migration 0011: explicit edition ownership for textual units.
--
-- A critical edition is an editorial representation of a work. It is not a
-- manuscript witness and it is not a translation. Textual units belonging
-- directly to an edition make that distinction explicit in the reader model.

BEGIN;

ALTER TABLE textual_units
    ADD COLUMN edition_id uuid REFERENCES editions(id) ON DELETE RESTRICT;

ALTER TABLE textual_units
    DROP CONSTRAINT textual_units_check;

ALTER TABLE textual_units
    ADD CONSTRAINT textual_units_source_check
    CHECK (num_nonnulls(witness_id, translation_id, edition_id) = 1);

CREATE INDEX textual_units_edition_idx
    ON textual_units(edition_id);

COMMIT;

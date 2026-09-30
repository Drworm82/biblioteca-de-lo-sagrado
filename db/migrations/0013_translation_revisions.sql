-- Biblioteca de lo Sagrado
-- Migration 0013: explicit translation revisions.
--
-- A translation is the translated work. A revision is a distinct editorial
-- state of that translation. Publication/edition remains represented by
-- editions; textual variants remain a separate layer.

BEGIN;

CREATE TABLE translation_revisions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  translation_id uuid NOT NULL REFERENCES translations(id) ON DELETE CASCADE,
  parent_revision_id uuid REFERENCES translation_revisions(id) ON DELETE RESTRICT,
  label text NOT NULL,
  revision_year integer,
  notes text,
  source_id uuid REFERENCES sources(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT translation_revisions_year_check
    CHECK (revision_year IS NULL OR revision_year BETWEEN -10000 AND 3000)
);

ALTER TABLE textual_units
  ADD COLUMN translation_revision_id uuid
  REFERENCES translation_revisions(id) ON DELETE RESTRICT;

CREATE INDEX translation_revisions_translation_idx
  ON translation_revisions(translation_id);

CREATE INDEX textual_units_translation_revision_idx
  ON textual_units(translation_revision_id);

COMMIT;

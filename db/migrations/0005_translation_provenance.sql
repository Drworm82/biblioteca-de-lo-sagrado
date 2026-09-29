-- Biblioteca de lo Sagrado
-- Migration 0005: explicit translation provenance and textual scope.
BEGIN;

ALTER TABLE translation_sources
    ADD COLUMN provenance_role text NOT NULL DEFAULT 'base_source',
    ADD COLUMN scope_type text NOT NULL DEFAULT 'work',
    ADD COLUMN scope_path_key text,
    ADD COLUMN scope_label text;

ALTER TABLE translation_sources
    ADD CONSTRAINT translation_sources_provenance_role_ck
    CHECK (provenance_role IN (
        'base_source',
        'comparative_witness',
        'reference_only',
        'editorial_basis'
    ));

ALTER TABLE translation_sources
    ADD CONSTRAINT translation_sources_scope_type_ck
    CHECK (scope_type IN ('work','passage','unit'));

CREATE INDEX translation_sources_translation_idx
    ON translation_sources(translation_id);

CREATE INDEX translation_sources_scope_idx
    ON translation_sources(scope_path_key);

COMMIT;

-- Reader-layer demonstration seed.
-- Uses only a short, explicitly identified textual sample.
BEGIN;

INSERT INTO textual_unit_contents(
    id,textual_unit_id,representation_type,text_content,normalized_text,source_id,notes
) VALUES
(
    pg_temp.entity_id('unit_content','matthew-24-3-regius-original'),
    pg_temp.entity_id('unit','matthew-24-3-regius'),
    'original',
    'Εἰπον ἡμῖν',
    'ειπον ημιν',
    pg_temp.entity_id('source','csntm-ga019'),
    'Short witness-level sample used by the textual-variant reader; it is not presented as the complete verse.'
),
(
    pg_temp.entity_id('unit_content','matthew-24-3-regius-transliteration'),
    pg_temp.entity_id('unit','matthew-24-3-regius'),
    'transliteration',
    'Eipon hēmin',
    NULL,
    pg_temp.entity_id('source','csntm-ga019'),
    'Transliteration of the short witness-level sample.'
);

COMMIT;

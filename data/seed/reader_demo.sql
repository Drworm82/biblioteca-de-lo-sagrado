-- Reader-layer demonstration seed.
-- Uses only a short, explicitly identified textual sample.
BEGIN;

CREATE FUNCTION pg_temp.entity_id(p_type text, p_key text)
RETURNS uuid
LANGUAGE plpgsql
AS $reader$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id
  FROM entities
  WHERE entity_type = p_type AND stable_key = p_key;

  IF v_id IS NULL THEN
    RAISE EXCEPTION 'Reader demo entity not found: % / %', p_type, p_key;
  END IF;

  RETURN v_id;
END $reader$;

INSERT INTO entities(entity_type, stable_key) VALUES
    ('unit_content','matthew-24-3-regius-original'),
    ('unit_content','matthew-24-3-regius-transliteration')
ON CONFLICT (entity_type, stable_key) DO NOTHING;

INSERT INTO textual_unit_contents(
    id,textual_unit_id,representation_type,text_content,normalized_text,source_id,notes
) VALUES
(
    gen_random_uuid(),
    pg_temp.entity_id('unit','matthew-24-3-regius'),
    'original',
    'Εἰπον ἡμῖν',
    'ειπον ημιν',
    pg_temp.entity_id('source','csntm-ga019'),
    'Short witness-level sample used by the textual-variant reader; it is not presented as the complete verse.'
),
(
    gen_random_uuid(),
    pg_temp.entity_id('unit','matthew-24-3-regius'),
    'transliteration',
    'Eipon hēmin',
    NULL,
    pg_temp.entity_id('source','csntm-ga019'),
    'Transliteration of the short witness-level sample.'
);

COMMIT;

-- Biblioteca de lo Sagrado
-- Migration 0012: move the Matthew critical-text pilot into edition-owned units.
--
-- This is a data correction, not a textual change. Westcott-Hort remains an
-- edition-level representation; the Spanish translation remains independent.

BEGIN;

DO $$
DECLARE
  v_edition uuid;
BEGIN
  SELECT id INTO v_edition
  FROM editions
  WHERE title = 'The New Testament in the Original Greek'
  LIMIT 1;

  IF v_edition IS NULL THEN
    RETURN;
  END IF;

  INSERT INTO entities(entity_type,stable_key) VALUES
    ('unit','matthew-24-3-westcott-hort'),
    ('unit','matthew-24-4-westcott-hort'),
    ('unit','matthew-24-5-westcott-hort')
  ON CONFLICT (entity_type,stable_key) DO NOTHING;

  INSERT INTO textual_units(id,parent_id,witness_id,translation_id,edition_id,unit_type,label,ordinal,path_key)
  VALUES
    ((SELECT id FROM entities WHERE entity_type='unit' AND stable_key='matthew-24-3-westcott-hort'),NULL,NULL,NULL,v_edition,'verse','Mateo 24:3',3,'matthew.24.3'),
    ((SELECT id FROM entities WHERE entity_type='unit' AND stable_key='matthew-24-4-westcott-hort'),NULL,NULL,NULL,v_edition,'verse','Mateo 24:4',4,'matthew.24.4'),
    ((SELECT id FROM entities WHERE entity_type='unit' AND stable_key='matthew-24-5-westcott-hort'),NULL,NULL,NULL,v_edition,'verse','Mateo 24:5',5,'matthew.24.5')
  ON CONFLICT (id) DO NOTHING;

  UPDATE textual_unit_contents tuc
     SET textual_unit_id = nu.id
    FROM textual_units old_u
    JOIN entities old_e ON old_e.id = old_u.id
    JOIN entities nu_e ON nu_e.entity_type='unit'
    JOIN textual_units nu ON nu.id = nu_e.id
   WHERE tuc.textual_unit_id = old_u.id
     AND old_e.stable_key = CASE tuc.representation_type
       WHEN 'critical_text' THEN CASE old_e.stable_key
         WHEN 'matthew-24-3-working-spanish' THEN 'matthew-24-3-westcott-hort'
         WHEN 'matthew-24-4-working-spanish' THEN 'matthew-24-4-westcott-hort'
         WHEN 'matthew-24-5-working-spanish' THEN 'matthew-24-5-westcott-hort'
       END
       WHEN 'transliteration' THEN CASE old_e.stable_key
         WHEN 'matthew-24-3-working-spanish' THEN 'matthew-24-3-westcott-hort'
         WHEN 'matthew-24-4-working-spanish' THEN 'matthew-24-4-westcott-hort'
         WHEN 'matthew-24-5-working-spanish' THEN 'matthew-24-5-westcott-hort'
       END
     END
     AND nu_e.stable_key = CASE old_e.stable_key
       WHEN 'matthew-24-3-working-spanish' THEN 'matthew-24-3-westcott-hort'
       WHEN 'matthew-24-4-working-spanish' THEN 'matthew-24-4-westcott-hort'
       WHEN 'matthew-24-5-working-spanish' THEN 'matthew-24-5-westcott-hort'
     END
     AND tuc.representation_type IN ('critical_text','transliteration');

END $$;

COMMIT;

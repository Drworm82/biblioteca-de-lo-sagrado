-- Biblioteca de lo Sagrado
-- Schema smoke tests for migrations 0001-0003.
BEGIN;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'entities','confidence_levels','languages','scripts','language_scripts',
    'places','place_names','periods','sources','source_locations','traditions',
    'works','work_traditions','textual_witnesses','manuscripts','manuscript_witnesses',
    'editions','edition_witnesses','translations','translation_sources','textual_units',
    'people','person_work_roles','dating_assertions','dating_assertion_sources','users',
    'roles','user_roles','evidence','evidence_sources','evidence_entities','claims',
    'claim_sources','claim_evidence','interpretations','interpretation_evidence',
    'interpretation_claims','interpretation_sources','interpretation_alternatives',
    'hypotheses','hypothesis_evidence','hypothesis_claims','hypothesis_interpretations',
    'hypothesis_sources','relations','relation_sources','relation_evidence','concepts',
    'concept_relations','contributions','contribution_sources','reviews','revisions',
    'publications','textual_variants','textual_variant_readings',
    'textual_variant_sources','textual_variant_reading_sources'
  ] LOOP
    IF to_regclass('public.' || t) IS NULL THEN RAISE EXCEPTION 'Missing table: %', t; END IF;
  END LOOP;
END $$;

DO $$
BEGIN
  IF (SELECT count(*) FROM confidence_levels) <> 5 THEN RAISE EXCEPTION 'Confidence seed incomplete'; END IF;
  IF (SELECT count(*) FROM roles) <> 4 THEN RAISE EXCEPTION 'Role seed incomplete'; END IF;
END $$;

-- Golden textual path plus variant apparatus.
DO $$
DECLARE
  e_work uuid := gen_random_uuid();
  e_wit_a uuid := gen_random_uuid();
  e_wit_b uuid := gen_random_uuid();
  e_unit uuid := gen_random_uuid();
  e_variant uuid := gen_random_uuid();
  e_read_a uuid := gen_random_uuid();
  e_read_b uuid := gen_random_uuid();
  lang uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e_work,'work','variant-test-work'),
    (e_wit_a,'textual_witness','variant-test-witness-a'),
    (e_wit_b,'textual_witness','variant-test-witness-b'),
    (e_unit,'textual_unit','variant-test-unit'),
    (e_variant,'textual_variant','variant-test'),
    (e_read_a,'textual_variant_reading','variant-reading-a'),
    (e_read_b,'textual_variant_reading','variant-reading-b');

  INSERT INTO works(id,title,status) VALUES(e_work,'Variant Test Work','draft');
  INSERT INTO languages(name,iso_639_3) VALUES('Variant Test Language','vtt') RETURNING id INTO lang;

  INSERT INTO textual_witnesses(id,work_id,witness_type,language_id)
    VALUES(e_wit_a,e_work,'manuscript',lang),(e_wit_b,e_work,'fragment',lang);

  INSERT INTO textual_units(id,witness_id,unit_type,label)
    VALUES(e_unit,e_wit_a,'line','1');

  INSERT INTO textual_variants(id,textual_unit_id,variant_type,description,status)
    VALUES(e_variant,e_unit,'lexical','Test lexical variation','documented');

  INSERT INTO textual_variant_readings(id,variant_id,witness_id,reading_text,language_id)
    VALUES
      (e_read_a,e_variant,e_wit_a,'reading A',lang),
      (e_read_b,e_variant,e_wit_b,'reading B',lang);

  IF (SELECT count(*) FROM textual_variant_readings WHERE variant_id=e_variant) <> 2
    THEN RAISE EXCEPTION 'Variant readings were not stored correctly';
  END IF;
END $$;

-- A revision may only point to a previous revision of the same entity.
DO $$
DECLARE e1 uuid := gen_random_uuid(); e2 uuid := gen_random_uuid(); r1 uuid; r2 uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e1,'work','revision-test-a'),(e2,'work','revision-test-b');

  INSERT INTO users(email,status) VALUES('schema-test@example.invalid','active') RETURNING id INTO r1;

  INSERT INTO revisions(entity_id,created_by_user_id,revision_number,content_jsonb)
    VALUES(e1,r1,1,'{}') RETURNING id INTO r2;

  BEGIN
    INSERT INTO revisions(entity_id,created_by_user_id,previous_revision_id,revision_number,content_jsonb)
      VALUES(e2,r1,r2,1,'{}');
    RAISE EXCEPTION 'Cross-entity revision lineage was accepted';
  EXCEPTION WHEN foreign_key_violation THEN
    NULL;
  END;
END $$;

-- Historical dating convention must be explicit.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name='dating_assertions' AND column_name='chronology_basis'
  ) THEN RAISE EXCEPTION 'Dating chronology basis missing'; END IF;
END $$;

ROLLBACK;

-- Biblioteca de lo Sagrado
-- Schema smoke tests for migrations 0001 and 0002.
-- Run in a disposable PostgreSQL database after applying all migrations.

BEGIN;

DO $$
DECLARE
  required_table text;
BEGIN
  FOREACH required_table IN ARRAY ARRAY[
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
    'publications'
  ] LOOP
    IF to_regclass('public.' || required_table) IS NULL THEN
      RAISE EXCEPTION 'Missing table: %', required_table;
    END IF;
  END LOOP;
END $$;

DO $$
BEGIN
  IF (SELECT count(*) FROM confidence_levels) <> 5 THEN
    RAISE EXCEPTION 'Confidence seed is incomplete';
  END IF;
  IF (SELECT count(*) FROM roles) <> 4 THEN
    RAISE EXCEPTION 'Role seed is incomplete';
  END IF;
END $$;

-- Provenance must be enforced by the database.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'place_names_source_fk'
      AND conrelid = 'place_names'::regclass
  ) THEN
    RAISE EXCEPTION 'place_names.source_id FK is missing';
  END IF;
END $$;

-- Golden path: one Work -> Witness -> Manuscript/Edition -> Translation.
DO $$
DECLARE
  e_trad uuid := gen_random_uuid();
  e_work uuid := gen_random_uuid();
  e_wit uuid := gen_random_uuid();
  e_man uuid := gen_random_uuid();
  e_edition uuid := gen_random_uuid();
  e_translation uuid := gen_random_uuid();
  lang uuid;
  conf uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e_trad,'tradition','test-tradition'),
    (e_work,'work','test-work'),
    (e_wit,'textual_witness','test-witness'),
    (e_man,'manuscript','test-manuscript'),
    (e_edition,'edition','test-edition'),
    (e_translation,'translation','test-translation');

  INSERT INTO traditions(id,name,tradition_type) VALUES(e_trad,'Test Tradition','test');
  INSERT INTO works(id,title,status) VALUES(e_work,'Test Work','draft');
  INSERT INTO work_traditions(work_id,tradition_id) VALUES(e_work,e_trad);

  INSERT INTO languages(name,iso_639_3) VALUES('Test language','tst') RETURNING id INTO lang;
  INSERT INTO textual_witnesses(id,work_id,witness_type,language_id)
    VALUES(e_wit,e_work,'manuscript',lang);
  INSERT INTO manuscripts(id,repository,shelfmark) VALUES(e_man,'Test Repository','TEST 1');
  INSERT INTO manuscript_witnesses(manuscript_id,witness_id) VALUES(e_man,e_wit);

  INSERT INTO editions(id,title,edition_type) VALUES(e_edition,'Test Critical Edition','critical');
  INSERT INTO edition_witnesses(edition_id,witness_id) VALUES(e_edition,e_wit);

  INSERT INTO translations(id,title,target_language_id)
    VALUES(e_translation,'Test Spanish Translation',lang);
  INSERT INTO translation_sources(translation_id,edition_id,source_type)
    VALUES(e_translation,e_edition,'primary');

  SELECT id INTO conf FROM confidence_levels WHERE key='documented';
  IF conf IS NULL THEN RAISE EXCEPTION 'Missing documented confidence'; END IF;
END $$;

-- Claim invariant: exactly one target is required.
DO $$
BEGIN
  BEGIN
    INSERT INTO entities(entity_type,stable_key) VALUES('claim','invalid-claim');
    INSERT INTO claims(id,subject_entity_id,predicate,confidence_id,status)
      SELECT id,id,'invalid',c.id,'draft'
      FROM entities e CROSS JOIN confidence_levels c
      WHERE e.stable_key='invalid-claim' AND c.key='documented';
    RAISE EXCEPTION 'Invalid claim was accepted';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;
END $$;

ROLLBACK;

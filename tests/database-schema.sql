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

-- 1-3. Textual transmission and variant apparatus.
DO $$
DECLARE
  e_work uuid := gen_random_uuid();
  e_wit_a uuid := gen_random_uuid();
  e_wit_b uuid := gen_random_uuid();
  e_unit uuid := gen_random_uuid();
  e_variant uuid := gen_random_uuid();
  e_read_a uuid := gen_random_uuid();
  e_read_b uuid := gen_random_uuid();
  e_translation uuid := gen_random_uuid();
  lang uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e_work,'work','case-textual-transmission'),
    (e_wit_a,'textual_witness','case-witness-a'),
    (e_wit_b,'textual_witness','case-witness-b'),
    (e_unit,'textual_unit','case-unit'),
    (e_variant,'textual_variant','case-variant'),
    (e_read_a,'textual_variant_reading','case-reading-a'),
    (e_read_b,'textual_variant_reading','case-reading-b'),
    (e_translation,'translation','case-translation');

  INSERT INTO works(id,title,status) VALUES(e_work,'Corpus Fixture: Textual Transmission','draft');
  INSERT INTO languages(name,iso_639_3) VALUES('Fixture Language','fxa') RETURNING id INTO lang;

  INSERT INTO textual_witnesses(id,work_id,witness_type,language_id)
    VALUES(e_wit_a,e_work,'manuscript',lang),(e_wit_b,e_work,'fragment',lang);

  INSERT INTO textual_units(id,witness_id,unit_type,label)
    VALUES(e_unit,e_wit_a,'line','1');

  INSERT INTO textual_variants(id,textual_unit_id,variant_type,description,status)
    VALUES(e_variant,e_unit,'lexical','Fixture variant','documented');

  INSERT INTO textual_variant_readings(id,variant_id,witness_id,reading_text,language_id)
    VALUES(e_read_a,e_variant,e_wit_a,'reading A',lang),
          (e_read_b,e_variant,e_wit_b,'reading B',lang);

  INSERT INTO translations(id,title,target_language_id)
    VALUES(e_translation,'Fixture Translation',lang);

  IF (SELECT count(*) FROM textual_variant_readings WHERE variant_id=e_variant) <> 2
    THEN RAISE EXCEPTION 'Variant readings were not stored independently';
  END IF;
END $$;

-- 4. Multiple datings must coexist and remain independently sourced.
DO $$
DECLARE e uuid := gen_random_uuid(); s1 uuid; s2 uuid; d1 uuid; d2 uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES(e,'work','case-multiple-datings');
  INSERT INTO works(id,title,status) VALUES(e,'Corpus Fixture: Multiple Datings','draft');

  INSERT INTO entities(entity_type,stable_key) VALUES
    ('source','case-dating-source-a'),('source','case-dating-source-b')
    RETURNING id INTO s1;
  INSERT INTO entities(entity_type,stable_key) VALUES('source','case-dating-source-b-copy')
    RETURNING id INTO s2;

  INSERT INTO sources(id,source_type,title) VALUES
    (s1,'academic','Dating Source A'),(s2,'academic','Dating Source B');

  INSERT INTO dating_assertions(id,entity_id,earliest,latest,precision,dating_method,confidence_id,chronology_basis)
    SELECT gen_random_uuid(),e,-500,-450,'range','method A',id,'astronomical_year'
    FROM confidence_levels WHERE key='plausible';

  SELECT da.id INTO d1 FROM dating_assertions da WHERE da.entity_id=e ORDER BY da.created_at LIMIT 1;

  INSERT INTO dating_assertions(id,entity_id,earliest,latest,precision,dating_method,confidence_id,chronology_basis)
    SELECT gen_random_uuid(),e,-430,-380,'range','method B',id,'astronomical_year'
    FROM confidence_levels WHERE key='possible';

  SELECT da.id INTO d2 FROM dating_assertions da WHERE da.entity_id=e ORDER BY da.created_at DESC LIMIT 1;

  INSERT INTO dating_assertion_sources(dating_assertion_id,source_id)
    VALUES(d1,s1),(d2,s2);

  IF (SELECT count(*) FROM dating_assertions WHERE entity_id=e) <> 2
    THEN RAISE EXCEPTION 'Multiple dating assertions did not coexist';
  END IF;
END $$;

-- 5. Evidence chain must remain layered.
DO $$
DECLARE
  e_entity uuid := gen_random_uuid();
  e_evidence uuid := gen_random_uuid();
  e_claim uuid := gen_random_uuid();
  e_interpretation uuid := gen_random_uuid();
  e_hypothesis uuid := gen_random_uuid();
  conf uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e_entity,'other','case-homo-naledi-subject'),
    (e_evidence,'evidence','case-homo-naledi-evidence'),
    (e_claim,'claim','case-homo-naledi-claim'),
    (e_interpretation,'interpretation','case-homo-naledi-interpretation'),
    (e_hypothesis,'hypothesis','case-homo-naledi-hypothesis');

  INSERT INTO confidence_levels(key,label,description)
    VALUES('fixture_temp','Fixture','Fixture confidence')
    ON CONFLICT (key) DO UPDATE SET label=EXCLUDED.label
    RETURNING id INTO conf;

  INSERT INTO evidence(id,evidence_type,description,observation,confidence_id)
    VALUES(e_evidence,'archaeological','Fixture archaeological evidence',
           'Human remains show a spatial distribution in a cave context.',conf);

  INSERT INTO evidence_entities(evidence_id,entity_id,role)
    VALUES(e_evidence,e_entity,'subject');

  INSERT INTO claims(id,subject_entity_id,predicate,value_text,confidence_id,status)
    VALUES(e_claim,e_entity,'has_observed_spatial_distribution',
           'documented observation',conf,'active');

  INSERT INTO claim_evidence(claim_id,evidence_id) VALUES(e_claim,e_evidence);

  INSERT INTO interpretations(id,title,statement,confidence_id,claimant_person_id,status)
    VALUES(e_interpretation,'Fixture interpretation',
           'The distribution may require intentional human involvement.',conf,
           NULL,'active');

  INSERT INTO interpretation_claims(interpretation_id,claim_id)
    VALUES(e_interpretation,e_claim);

  INSERT INTO hypotheses(id,statement,confidence_id,status)
    VALUES(e_hypothesis,
           'Fixture hypothesis about socially elaborated mortuary behavior.',
           conf,'proposed');

  INSERT INTO hypothesis_interpretations(hypothesis_id,interpretation_id)
    VALUES(e_hypothesis,e_interpretation);

  IF NOT EXISTS (
    SELECT 1 FROM claim_evidence WHERE claim_id=e_claim AND evidence_id=e_evidence
  ) THEN RAISE EXCEPTION 'Evidence was not connected to claim'; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM hypothesis_interpretations
    WHERE hypothesis_id=e_hypothesis AND interpretation_id=e_interpretation
  ) THEN RAISE EXCEPTION 'Hypothesis was not connected to interpretation'; END IF;
END $$;

-- 6. Relations require explicit confidence and provenance instead of automatic dependence.
DO $$
DECLARE a uuid := gen_random_uuid(); b uuid := gen_random_uuid(); r uuid := gen_random_uuid(); conf uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (a,'work','case-flood-tradition-a'),(b,'work','case-flood-tradition-b'),
    (r,'relation','case-flood-parallel');

  SELECT id INTO conf FROM confidence_levels WHERE key='plausible';

  INSERT INTO relations(id,subject_entity_id,predicate,object_entity_id,confidence_id,status)
    VALUES(r,a,'parallel',b,conf,'active');

  IF NOT EXISTS (SELECT 1 FROM relations WHERE id=r AND predicate='parallel') THEN
    RAISE EXCEPTION 'Parallel relation was not stored';
  END IF;
END $$;

-- 7. Cross-entity revision lineage must fail.
DO $$
DECLARE e1 uuid := gen_random_uuid(); e2 uuid := gen_random_uuid(); u uuid; r1 uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e1,'work','revision-case-a'),(e2,'work','revision-case-b');

  INSERT INTO users(email,status) VALUES('schema-test-2@example.invalid','active') RETURNING id INTO u;

  INSERT INTO revisions(entity_id,created_by_user_id,revision_number,content_jsonb)
    VALUES(e1,u,1,'{}') RETURNING id INTO r1;

  BEGIN
    INSERT INTO revisions(entity_id,created_by_user_id,previous_revision_id,revision_number,content_jsonb)
      VALUES(e2,u,r1,1,'{}');
    RAISE EXCEPTION 'Cross-entity revision lineage was accepted';
  EXCEPTION WHEN foreign_key_violation THEN
    NULL;
  END;
END $$;

ROLLBACK;

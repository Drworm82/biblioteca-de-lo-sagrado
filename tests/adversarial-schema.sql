-- Biblioteca de lo Sagrado
-- Adversarial schema tests: ambiguous, incomplete, conflicting and multi-source cases.
BEGIN;

-- 1. A textual witness may exist before its work is identified.
DO $$
DECLARE
  w uuid := gen_random_uuid();
  e uuid := gen_random_uuid();
BEGIN
  INSERT INTO entities(id,entity_type,stable_key)
    VALUES(e,'textual_witness','adversarial-unidentified-witness');

  INSERT INTO textual_witnesses(id,work_id,witness_type,title_or_label)
    VALUES(e,NULL,'fragment','Unidentified fragment');

  IF (SELECT work_id FROM textual_witnesses WHERE id=e) IS NOT NULL THEN
    RAISE EXCEPTION 'Unidentified witness was forced to have a work';
  END IF;
END $$;

-- 2. A translation may have multiple base sources of different kinds.
DO $$
DECLARE
  e_work uuid := gen_random_uuid();
  e_wit uuid := gen_random_uuid();
  e_translation uuid := gen_random_uuid();
  e_edition uuid := gen_random_uuid();
  e_source uuid := gen_random_uuid();
  lang uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e_work,'work','adversarial-derived-translation-work'),
    (e_wit,'textual_witness','adversarial-derived-translation-witness'),
    (e_translation,'translation','adversarial-derived-translation'),
    (e_edition,'edition','adversarial-derived-edition'),
    (e_source,'source','adversarial-derived-source');

  INSERT INTO works(id,title,status)
    VALUES(e_work,'Adversarial Derived Translation Work','draft');

  INSERT INTO languages(name,iso_639_3)
    VALUES('Adversarial Language','adl') RETURNING id INTO lang;

  INSERT INTO textual_witnesses(id,work_id,witness_type,language_id)
    VALUES(e_wit,e_work,'manuscript',lang);

  INSERT INTO editions(id,title,edition_type)
    VALUES(e_edition,'Adversarial Critical Edition','critical');

  INSERT INTO translations(id,title,target_language_id)
    VALUES(e_translation,'Adversarial Translation',lang);

  INSERT INTO translation_sources(translation_id,edition_id,source_type)
    VALUES(e_translation,e_edition,'base_edition');

  INSERT INTO translation_sources(translation_id,witness_id,source_type)
    VALUES(e_translation,e_wit,'base_witness');

  IF (SELECT count(*) FROM translation_sources WHERE translation_id=e_translation) <> 2
    THEN RAISE EXCEPTION 'Translation did not retain multiple base sources';
  END IF;
END $$;

-- 3. Incompatible dating assertions must coexist instead of overwriting one another.
DO $$
DECLARE
  e uuid := gen_random_uuid();
BEGIN
  INSERT INTO entities(id,entity_type,stable_key)
    VALUES(e,'work','adversarial-conflicting-datings');

  INSERT INTO works(id,title,status)
    VALUES(e,'Adversarial Conflicting Datings','draft');

  INSERT INTO dating_assertions(
    id,entity_id,earliest,latest,precision,dating_method,confidence_id,chronology_basis
  )
  SELECT gen_random_uuid(),e,-500,-450,'range','method A',id,'astronomical_year'
  FROM confidence_levels WHERE key='plausible';

  INSERT INTO dating_assertions(
    id,entity_id,earliest,latest,precision,dating_method,confidence_id,chronology_basis
  )
  SELECT gen_random_uuid(),e,100,150,'range','method B',id,'astronomical_year'
  FROM confidence_levels WHERE key='possible';

  IF (SELECT count(*) FROM dating_assertions WHERE entity_id=e) <> 2
    THEN RAISE EXCEPTION 'Conflicting dating assertions were collapsed';
  END IF;
END $$;

-- 4. Contradictory claims and their evidence must remain independently representable.
DO $$
DECLARE
  e_subject uuid := gen_random_uuid();
  e_claim_a uuid := gen_random_uuid();
  e_claim_b uuid := gen_random_uuid();
  e_evidence_a uuid := gen_random_uuid();
  e_evidence_b uuid := gen_random_uuid();
  c uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e_subject,'work','adversarial-contradictory-claims'),
    (e_claim_a,'claim','adversarial-claim-a'),
    (e_claim_b,'claim','adversarial-claim-b'),
    (e_evidence_a,'evidence','adversarial-evidence-a'),
    (e_evidence_b,'evidence','adversarial-evidence-b');

  SELECT id INTO c FROM confidence_levels WHERE key='plausible';

  INSERT INTO evidence(id,evidence_type,description,observation,confidence_id)
    VALUES
      (e_evidence_a,'textual','Evidence A','Source A supports attribution to author A.',c),
      (e_evidence_b,'textual','Evidence B','Source B supports attribution to author B.',c);

  INSERT INTO claims(
    id,subject_entity_id,predicate,value_text,confidence_id,status
  )
  VALUES
    (e_claim_a,e_subject,'attributed_author','author A',c,'active'),
    (e_claim_b,e_subject,'attributed_author','author B',c,'active');

  INSERT INTO claim_evidence(claim_id,evidence_id)
    VALUES(e_claim_a,e_evidence_a),(e_claim_b,e_evidence_b);

  IF (SELECT count(*) FROM claims
      WHERE subject_entity_id=e_subject AND predicate='attributed_author') <> 2
    THEN RAISE EXCEPTION 'Contradictory claims were collapsed';
  END IF;
END $$;

-- 5. Alternative interpretations must be explicit and can coexist.
DO $$
DECLARE
  e1 uuid := gen_random_uuid();
  e2 uuid := gen_random_uuid();
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e1,'interpretation','adversarial-interpretation-a'),
    (e2,'interpretation','adversarial-interpretation-b');

  INSERT INTO interpretations(id,title,statement,confidence_id,status)
  SELECT e1,'Interpretation A','Explanation A',id,'active'
  FROM confidence_levels WHERE key='plausible';

  INSERT INTO interpretations(id,title,statement,confidence_id,status)
  SELECT e2,'Interpretation B','Explanation B',id,'possible'
  FROM confidence_levels WHERE key='possible';

  INSERT INTO interpretation_alternatives(interpretation_id,alternative_interpretation_id)
    VALUES(e1,e2),(e2,e1);

  IF (SELECT count(*) FROM interpretation_alternatives
      WHERE interpretation_id IN (e1,e2)) <> 2
    THEN RAISE EXCEPTION 'Alternative interpretations were not retained';
  END IF;
END $$;

-- 6. Different relation hypotheses between the same entities must remain explicit.
DO $$
DECLARE
  a uuid := gen_random_uuid();
  b uuid := gen_random_uuid();
  r1 uuid := gen_random_uuid();
  r2 uuid := gen_random_uuid();
  c uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (a,'work','adversarial-relation-a'),
    (b,'work','adversarial-relation-b'),
    (r1,'relation','adversarial-influence'),
    (r2,'relation','adversarial-dependence');

  SELECT id INTO c FROM confidence_levels WHERE key='possible';

  INSERT INTO relations(
    id,subject_entity_id,predicate,object_entity_id,confidence_id,status
  )
  VALUES
    (r1,a,'influence',b,c,'active'),
    (r2,a,'dependence',b,c,'active');

  IF (SELECT count(*) FROM relations
      WHERE subject_entity_id=a AND object_entity_id=b) <> 2
    THEN RAISE EXCEPTION 'Distinct relation hypotheses were collapsed';
  END IF;
END $$;

-- 7. A publication cannot point to a revision belonging to another entity.
DO $$
DECLARE
  e1 uuid := gen_random_uuid();
  e2 uuid := gen_random_uuid();
  u uuid;
  r1 uuid;
BEGIN
  INSERT INTO entities(id,entity_type,stable_key) VALUES
    (e1,'work','adversarial-publication-a'),
    (e2,'work','adversarial-publication-b');

  INSERT INTO users(email,status)
    VALUES('schema-adversarial@example.invalid','active')
    RETURNING id INTO u;

  INSERT INTO revisions(entity_id,created_by_user_id,revision_number,content_jsonb)
    VALUES(e1,u,1,'{}')
    RETURNING id INTO r1;

  BEGIN
    INSERT INTO publications(entity_id,revision_id,published_by_user_id)
      VALUES(e2,r1,u);
    RAISE EXCEPTION 'Cross-entity publication was accepted';
  EXCEPTION WHEN foreign_key_violation THEN
    NULL;
  END;
END $$;

ROLLBACK;

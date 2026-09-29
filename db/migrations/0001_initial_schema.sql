-- Biblioteca de lo Sagrado / PostgreSQL schema v1.1
-- Migration 0001: initial relational schema
BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE entities(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), entity_type text NOT NULL,
 stable_key text NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(), UNIQUE(entity_type,stable_key)
);
CREATE INDEX entities_type_idx ON entities(entity_type);

CREATE TABLE confidence_levels(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), key text NOT NULL UNIQUE,
 label text NOT NULL, description text, ordinal integer
);
INSERT INTO confidence_levels(key,label,description,ordinal) VALUES
('documented','Documentado','Respaldado directamente por evidencia o documentación suficiente.',1),
('strongly_supported','Fuertemente respaldado','Evidencia convergente y base académica sólida, con posible incertidumbre.',2),
('plausible','Plausible','Compatible con la evidencia, pero no demostrado.',3),
('possible','Posible','Compatible pero con evidencia insuficiente.',4),
('unsupported','No demostrado','No existe evidencia suficiente para sostenerlo.',5);

CREATE TABLE languages(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), name text NOT NULL,
 iso_639_1 text, iso_639_3 text, historical_name text, description text
);
CREATE TABLE scripts(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), name text NOT NULL,
 iso_15924 text, description text
);
CREATE TABLE language_scripts(
 language_id uuid NOT NULL REFERENCES languages(id) ON DELETE RESTRICT,
 script_id uuid NOT NULL REFERENCES scripts(id) ON DELETE RESTRICT,
 valid_from integer, valid_to integer, notes text,
 PRIMARY KEY(language_id,script_id)
);

CREATE TABLE places(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
 place_type text NOT NULL, description text, latitude double precision,
 longitude double precision, valid_from integer, valid_to integer,
 CHECK(latitude IS NULL OR latitude BETWEEN -90 AND 90),
 CHECK(longitude IS NULL OR longitude BETWEEN -180 AND 180)
);
CREATE TABLE place_names(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), place_id uuid NOT NULL REFERENCES places(id) ON DELETE RESTRICT,
 name text NOT NULL, language_id uuid REFERENCES languages(id) ON DELETE RESTRICT,
 name_type text NOT NULL, valid_from integer, valid_to integer,
 source_id uuid, UNIQUE(place_id,name,name_type)
);

CREATE TABLE periods(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, name text NOT NULL,
 earliest integer, latest integer, description text,
 CHECK(earliest IS NULL OR latest IS NULL OR earliest<=latest)
);

CREATE TABLE sources(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, source_type text NOT NULL,
 title text NOT NULL, author_text text, publisher text, publication_year integer,
 isbn text, doi text, url text, accessed_at timestamptz, notes text
);
CREATE TABLE source_locations(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 page text, volume text, chapter text, section text, paragraph text, line text,
 figure text, "table" text, locator_text text, url text
);

CREATE TABLE traditions(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, name text NOT NULL,
 description text, tradition_type text
);
CREATE TABLE works(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, title text NOT NULL,
 description text, status text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE work_traditions(
 work_id uuid NOT NULL REFERENCES works(id) ON DELETE RESTRICT,
 tradition_id uuid NOT NULL REFERENCES traditions(id) ON DELETE RESTRICT,
 relationship_type text, confidence_id uuid REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 source_id uuid REFERENCES sources(id) ON DELETE RESTRICT, notes text,
 PRIMARY KEY(work_id,tradition_id)
);

CREATE TABLE textual_witnesses(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
 work_id uuid REFERENCES works(id) ON DELETE RESTRICT, witness_type text NOT NULL,
 title_or_label text, language_id uuid REFERENCES languages(id) ON DELETE RESTRICT,
 script_id uuid REFERENCES scripts(id) ON DELETE RESTRICT, date_note text, description text,
 CHECK(witness_type IN('manuscript','fragment','inscription','quotation','ancient_translation','other'))
);
CREATE TABLE manuscripts(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
 repository text, shelfmark text, material text, provenance_note text,
 findspot_id uuid REFERENCES places(id) ON DELETE RESTRICT,
 current_location_id uuid REFERENCES places(id) ON DELETE RESTRICT, description text
);
CREATE TABLE manuscript_witnesses(
 manuscript_id uuid NOT NULL REFERENCES manuscripts(id) ON DELETE RESTRICT,
 witness_id uuid NOT NULL REFERENCES textual_witnesses(id) ON DELETE RESTRICT,
 position_note text, PRIMARY KEY(manuscript_id,witness_id)
);

CREATE TABLE editions(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, title text NOT NULL,
 publisher text, publication_year integer, edition_type text, isbn text, doi text,
 source_id uuid REFERENCES sources(id) ON DELETE RESTRICT
);
CREATE TABLE edition_witnesses(
 edition_id uuid NOT NULL REFERENCES editions(id) ON DELETE RESTRICT,
 witness_id uuid NOT NULL REFERENCES textual_witnesses(id) ON DELETE RESTRICT,
 role text, notes text, PRIMARY KEY(edition_id,witness_id)
);

CREATE TABLE translations(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, title text NOT NULL,
 target_language_id uuid NOT NULL REFERENCES languages(id) ON DELETE RESTRICT,
 translator_notes text, publication_year integer, description text
);
CREATE TABLE translation_sources(
 translation_id uuid NOT NULL REFERENCES translations(id) ON DELETE RESTRICT,
 edition_id uuid REFERENCES editions(id) ON DELETE RESTRICT,
 witness_id uuid REFERENCES textual_witnesses(id) ON DELETE RESTRICT,
 source_type text NOT NULL, notes text,
 CHECK(num_nonnulls(edition_id,witness_id)>=1)
);

CREATE TABLE textual_units(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
 parent_id uuid REFERENCES textual_units(id) ON DELETE RESTRICT,
 witness_id uuid REFERENCES textual_witnesses(id) ON DELETE RESTRICT,
 translation_id uuid REFERENCES translations(id) ON DELETE RESTRICT,
 unit_type text NOT NULL, label text, ordinal integer, path_key text,
 CHECK(num_nonnulls(witness_id,translation_id)>=1)
);

CREATE TABLE people(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, name text NOT NULL,
 description text, birth_note text, death_note text
);
CREATE TABLE person_work_roles(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), person_id uuid NOT NULL REFERENCES people(id) ON DELETE RESTRICT,
 work_id uuid NOT NULL REFERENCES works(id) ON DELETE RESTRICT, role text NOT NULL,
 confidence_id uuid REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 source_id uuid REFERENCES sources(id) ON DELETE RESTRICT, notes text,
 UNIQUE(person_id,work_id,role)
);

CREATE TABLE dating_assertions(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), entity_id uuid NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
 earliest integer, latest integer, precision text, dating_method text,
 confidence_id uuid REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 claimant_person_id uuid REFERENCES people(id) ON DELETE RESTRICT, notes text,
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK(earliest IS NULL OR latest IS NULL OR earliest<=latest)
);
CREATE TABLE dating_assertion_sources(
 dating_assertion_id uuid NOT NULL REFERENCES dating_assertions(id) ON DELETE RESTRICT,
 source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
 UNIQUE(dating_assertion_id,source_id,source_location_id)
);

CREATE TABLE users(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), email text NOT NULL UNIQUE,
 display_name text, status text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE roles(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), key text NOT NULL UNIQUE, name text NOT NULL
);
CREATE TABLE user_roles(
 user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 role_id uuid NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
 PRIMARY KEY(user_id,role_id)
);
INSERT INTO roles(key,name) VALUES
('registered_user','Registered user'),('contributor','Contributor'),
('editor','Editor'),('administrator','Administrator');

CREATE TABLE evidence(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, evidence_type text NOT NULL,
 description text NOT NULL, observation text, confidence_id uuid REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 created_by_user_id uuid REFERENCES users(id) ON DELETE RESTRICT,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE evidence_sources(
 evidence_id uuid NOT NULL REFERENCES evidence(id) ON DELETE RESTRICT,
 source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
 UNIQUE(evidence_id,source_id,source_location_id)
);
CREATE TABLE evidence_entities(
 evidence_id uuid NOT NULL REFERENCES evidence(id) ON DELETE RESTRICT,
 entity_id uuid NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
 role text NOT NULL, UNIQUE(evidence_id,entity_id,role)
);

CREATE TABLE claims(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
 subject_entity_id uuid NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
 predicate text NOT NULL, object_entity_id uuid REFERENCES entities(id) ON DELETE RESTRICT,
 value_text text, value_number numeric, value_date date, value_json jsonb,
 confidence_id uuid NOT NULL REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 claimant_person_id uuid REFERENCES people(id) ON DELETE RESTRICT,
 status text NOT NULL, notes text,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK(num_nonnulls(object_entity_id,value_text,value_number,value_date,value_json)=1)
);
CREATE TABLE claim_sources(
 claim_id uuid NOT NULL REFERENCES claims(id) ON DELETE RESTRICT,
 source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
 UNIQUE(claim_id,source_id,source_location_id)
);
CREATE TABLE claim_evidence(
 claim_id uuid NOT NULL REFERENCES claims(id) ON DELETE RESTRICT,
 evidence_id uuid NOT NULL REFERENCES evidence(id) ON DELETE RESTRICT,
 PRIMARY KEY(claim_id,evidence_id)
);

CREATE TABLE interpretations(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, title text NOT NULL,
 statement text NOT NULL, confidence_id uuid NOT NULL REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 claimant_person_id uuid REFERENCES people(id) ON DELETE RESTRICT, status text NOT NULL,
 notes text, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE interpretation_evidence(
 interpretation_id uuid NOT NULL REFERENCES interpretations(id) ON DELETE RESTRICT,
 evidence_id uuid NOT NULL REFERENCES evidence(id) ON DELETE RESTRICT,
 PRIMARY KEY(interpretation_id,evidence_id)
);
CREATE TABLE interpretation_claims(
 interpretation_id uuid NOT NULL REFERENCES interpretations(id) ON DELETE RESTRICT,
 claim_id uuid NOT NULL REFERENCES claims(id) ON DELETE RESTRICT,
 PRIMARY KEY(interpretation_id,claim_id)
);
CREATE TABLE interpretation_sources(
 interpretation_id uuid NOT NULL REFERENCES interpretations(id) ON DELETE RESTRICT,
 source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
 UNIQUE(interpretation_id,source_id,source_location_id)
);
CREATE TABLE interpretation_alternatives(
 interpretation_id uuid NOT NULL REFERENCES interpretations(id) ON DELETE RESTRICT,
 alternative_interpretation_id uuid NOT NULL REFERENCES interpretations(id) ON DELETE RESTRICT,
 PRIMARY KEY(interpretation_id,alternative_interpretation_id),
 CHECK(interpretation_id<>alternative_interpretation_id)
);

CREATE TABLE hypotheses(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, statement text NOT NULL,
 confidence_id uuid NOT NULL REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 claimant_person_id uuid REFERENCES people(id) ON DELETE RESTRICT, status text NOT NULL,
 notes text, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE hypothesis_evidence(
 hypothesis_id uuid NOT NULL REFERENCES hypotheses(id) ON DELETE RESTRICT,
 evidence_id uuid NOT NULL REFERENCES evidence(id) ON DELETE RESTRICT,
 PRIMARY KEY(hypothesis_id,evidence_id)
);
CREATE TABLE hypothesis_claims(
 hypothesis_id uuid NOT NULL REFERENCES hypotheses(id) ON DELETE RESTRICT,
 claim_id uuid NOT NULL REFERENCES claims(id) ON DELETE RESTRICT,
 PRIMARY KEY(hypothesis_id,claim_id)
);
CREATE TABLE hypothesis_interpretations(
 hypothesis_id uuid NOT NULL REFERENCES hypotheses(id) ON DELETE RESTRICT,
 interpretation_id uuid NOT NULL REFERENCES interpretations(id) ON DELETE RESTRICT,
 PRIMARY KEY(hypothesis_id,interpretation_id)
);
CREATE TABLE hypothesis_sources(
 hypothesis_id uuid NOT NULL REFERENCES hypotheses(id) ON DELETE RESTRICT,
 source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
 UNIQUE(hypothesis_id,source_id,source_location_id)
);

CREATE TABLE relations(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT,
 subject_entity_id uuid NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
 predicate text NOT NULL, object_entity_id uuid NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
 confidence_id uuid NOT NULL REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 temporal_context text, notes text, status text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
 CHECK(subject_entity_id<>object_entity_id OR predicate='related_to')
);
CREATE TABLE relation_sources(
 relation_id uuid NOT NULL REFERENCES relations(id) ON DELETE RESTRICT,
 source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
 UNIQUE(relation_id,source_id,source_location_id)
);
CREATE TABLE relation_evidence(
 relation_id uuid NOT NULL REFERENCES relations(id) ON DELETE RESTRICT,
 evidence_id uuid NOT NULL REFERENCES evidence(id) ON DELETE RESTRICT,
 PRIMARY KEY(relation_id,evidence_id)
);

CREATE TABLE concepts(
 id uuid PRIMARY KEY REFERENCES entities(id) ON DELETE RESTRICT, name text NOT NULL,
 description text, concept_type text
);
CREATE TABLE concept_relations(
 concept_id uuid NOT NULL REFERENCES concepts(id) ON DELETE RESTRICT,
 related_concept_id uuid NOT NULL REFERENCES concepts(id) ON DELETE RESTRICT,
 relation_type text NOT NULL, confidence_id uuid REFERENCES confidence_levels(id) ON DELETE RESTRICT,
 source_id uuid REFERENCES sources(id) ON DELETE RESTRICT,
 PRIMARY KEY(concept_id,related_concept_id,relation_type),
 CHECK(concept_id<>related_concept_id)
);

CREATE TABLE contributions(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 submitted_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 entity_id uuid REFERENCES entities(id) ON DELETE RESTRICT,
 contribution_type text NOT NULL, proposed_content jsonb NOT NULL, reason text,
 status text NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE contribution_sources(
 contribution_id uuid NOT NULL REFERENCES contributions(id) ON DELETE RESTRICT,
 source_id uuid NOT NULL REFERENCES sources(id) ON DELETE RESTRICT,
 source_location_id uuid REFERENCES source_locations(id) ON DELETE RESTRICT,
 UNIQUE(contribution_id,source_id,source_location_id)
);
CREATE TABLE reviews(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 contribution_id uuid NOT NULL REFERENCES contributions(id) ON DELETE RESTRICT,
 reviewer_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 decision text NOT NULL, comment text, created_at timestamptz NOT NULL DEFAULT now(),
 CHECK(decision IN('pending','needs_revision','approved','rejected'))
);
CREATE TABLE revisions(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 entity_id uuid NOT NULL REFERENCES entities(id) ON DELETE RESTRICT,
 contribution_id uuid REFERENCES contributions(id) ON DELETE RESTRICT,
 created_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 previous_revision_id uuid REFERENCES revisions(id) ON DELETE RESTRICT,
 revision_number integer NOT NULL, content_jsonb jsonb NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(entity_id,revision_number), UNIQUE(entity_id,id)
);
CREATE TABLE publications(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), entity_id uuid NOT NULL,
 revision_id uuid NOT NULL, published_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
 published_at timestamptz NOT NULL DEFAULT now(),
 FOREIGN KEY(entity_id,revision_id) REFERENCES revisions(entity_id,id) ON DELETE RESTRICT
);

CREATE INDEX work_traditions_tradition_idx ON work_traditions(tradition_id);
CREATE INDEX textual_witnesses_work_idx ON textual_witnesses(work_id);
CREATE INDEX textual_witnesses_language_idx ON textual_witnesses(language_id);
CREATE INDEX manuscripts_findspot_idx ON manuscripts(findspot_id);
CREATE INDEX manuscripts_current_location_idx ON manuscripts(current_location_id);
CREATE INDEX textual_units_parent_idx ON textual_units(parent_id);
CREATE INDEX textual_units_witness_idx ON textual_units(witness_id);
CREATE INDEX textual_units_translation_idx ON textual_units(translation_id);
CREATE INDEX place_names_place_idx ON place_names(place_id);
CREATE INDEX dating_assertions_entity_idx ON dating_assertions(entity_id);
CREATE INDEX dating_assertions_confidence_idx ON dating_assertions(confidence_id);
CREATE INDEX source_locations_source_idx ON source_locations(source_id);
CREATE INDEX evidence_sources_source_idx ON evidence_sources(source_id);
CREATE INDEX evidence_entities_entity_idx ON evidence_entities(entity_id);
CREATE INDEX claims_subject_idx ON claims(subject_entity_id);
CREATE INDEX claims_object_idx ON claims(object_entity_id);
CREATE INDEX claims_predicate_idx ON claims(predicate);
CREATE INDEX claim_sources_source_idx ON claim_sources(source_id);
CREATE INDEX claim_evidence_evidence_idx ON claim_evidence(evidence_id);
CREATE INDEX relations_subject_idx ON relations(subject_entity_id);
CREATE INDEX relations_object_idx ON relations(object_entity_id);
CREATE INDEX relations_predicate_idx ON relations(predicate);
CREATE INDEX relation_sources_source_idx ON relation_sources(source_id);
CREATE INDEX contributions_status_idx ON contributions(status);
CREATE INDEX reviews_contribution_created_idx ON reviews(contribution_id,created_at);
CREATE INDEX revisions_entity_revision_idx ON revisions(entity_id,revision_number);
CREATE INDEX publications_entity_published_idx ON publications(entity_id,published_at);
CREATE INDEX publications_revision_idx ON publications(revision_id);

COMMIT;

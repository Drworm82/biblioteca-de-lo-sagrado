# Esquema relacional PostgreSQL — diseño v1

Este documento convierte el modelo conceptual v2 en tablas, cardinalidades, claves e índices. No constituye todavía una migración ejecutable.

## Convenciones

- PostgreSQL.
- UUID como identificador técnico de entidades y registros.
- `created_at` y `updated_at` en entidades mutables.
- `stable_key` único para identidad editorial estable cuando corresponda.
- Las fechas históricas no se almacenan como un único campo `date` cuando existe incertidumbre.
- Las relaciones editoriales importantes conservan provenance.
- Los nombres visibles no son claves primarias.

## 1. Registro transversal

### entities

| Campo | Tipo conceptual | Restricción |
|---|---|---|
| id | uuid | PK |
| entity_type | text | NOT NULL |
| stable_key | text | UNIQUE |
| created_at | timestamptz | NOT NULL |
| updated_at | timestamptz | NOT NULL |

Índices:

- UNIQUE(entity_type, stable_key)
- INDEX(entity_type)

El registro permite que Claims y Relations apunten a cualquier entidad de dominio.

---

## 2. Tradiciones

### traditions

| Campo | Tipo | Restricción |
|---|---|---|
| id | uuid | PK/FK entities.id |
| name | text | NOT NULL |
| description | text | NULL |
| tradition_type | text | NULL |

Una tradición puede tener múltiples obras.

---

## 3. Obras

### works

| Campo | Tipo | Restricción |
|---|---|---|
| id | uuid | PK/FK entities.id |
| title | text | NOT NULL |
| description | text | NULL |
| tradition_id | uuid | FK traditions.id, NULL |
| status | text | NOT NULL |
| created_at | timestamptz | NOT NULL |
| updated_at | timestamptz | NOT NULL |

No existe `author_id`.

Una obra puede tener múltiples autores atribuidos mediante `person_work_roles`.

Una obra puede pertenecer a una o varias tradiciones si posteriormente se modela la relación many-to-many. La FK directa debe considerarse un atajo opcional, no una limitación permanente.

---

## 4. Testimonios textuales

### textual_witnesses

| Campo | Tipo | Restricción |
|---|---|---|
| id | uuid | PK/FK entities.id |
| work_id | uuid | FK works.id, NULL |
| witness_type | text | NOT NULL |
| title_or_label | text | NULL |
| language_id | uuid | FK languages.id, NULL |
| script_id | uuid | FK scripts.id, NULL |
| date_note | text | NULL |
| description | text | NULL |

Tipos iniciales:

- manuscript
- fragment
- inscription
- quotation
- ancient_translation
- other

Un Work puede tener muchos TextualWitness.

Un TextualWitness puede estar asociado a un Manuscript, pero no necesariamente.

---

## 5. Manuscritos

### manuscripts

| Campo | Tipo | Restricción |
|---|---|---|
| id | uuid | PK/FK entities.id |
| repository | text | NULL |
| shelfmark | text | NULL |
| material | text | NULL |
| provenance_note | text | NULL |
| findspot_id | uuid | FK places.id, NULL |
| current_location_id | uuid | FK places.id, NULL |
| description | text | NULL |

### manuscript_witnesses

Tabla puente:

- manuscript_id FK manuscripts.id
- witness_id FK textual_witnesses.id
- position_note
- UNIQUE(manuscript_id, witness_id)

Esto permite que un manuscrito conserve varios testimonios.

---

## 6. Ediciones

### editions

| Campo | Tipo |
|---|---|
| id | uuid PK/FK entities.id |
| title | text NOT NULL |
| publisher | text NULL |
| publication_year | integer NULL |
| edition_type | text NULL |
| isbn | text NULL |
| doi | text NULL |
| source_id | uuid FK sources.id NULL |

### edition_witnesses

- edition_id
- witness_id
- role
- notes

Una edición puede utilizar múltiples testimonios.

---

## 7. Traducciones

### translations

| Campo | Tipo |
|---|---|
| id | uuid PK/FK entities.id |
| title | text NOT NULL |
| target_language_id | uuid FK languages.id |
| translator_notes | text NULL |
| publication_year | integer NULL |
| description | text NULL |

### translation_sources

- translation_id
- edition_id NULL
- witness_id NULL
- source_type NOT NULL
- notes

Restricción conceptual:

Al menos uno de `edition_id` o `witness_id` debe estar presente.

Una traducción puede basarse en múltiples fuentes.

---

## 8. Unidades textuales

### textual_units

| Campo | Tipo |
|---|---|
| id | uuid PK/FK entities.id |
| parent_id | uuid FK textual_units.id NULL |
| witness_id | uuid FK textual_witnesses.id NULL |
| translation_id | uuid FK translations.id NULL |
| unit_type | text NOT NULL |
| label | text NULL |
| ordinal | integer NULL |
| path_key | text NULL |

La jerarquía se obtiene mediante `parent_id`.

No se debe asumir que todas las unidades pertenecen directamente a un Work.

Ejemplos:

- libro → capítulo → verso
- canto → línea
- logion
- inscripción → línea

La combinación de `witness_id` y `translation_id` permite distinguir unidades de testimonios originales de unidades de traducciones.

---

## 9. Lenguas y escrituras

### languages

- id
- name
- iso_639_1 NULL
- iso_639_3 NULL
- historical_name NULL
- description NULL

### scripts

- id
- name
- iso_15924 NULL
- description NULL

### language_scripts

- language_id
- script_id
- valid_from NULL
- valid_to NULL
- notes

---

## 10. Personas

### people

- id PK/FK entities.id
- name
- description
- birth_note
- death_note

### person_work_roles

- id
- person_id
- work_id
- role
- confidence_id NULL
- source_id NULL
- notes

UNIQUE(person_id, work_id, role)

Esto permite distinguir:

- autor
- atribución tradicional
- compilador
- traductor
- escriba
- redactor
- editor
- investigador
- descubridor

---

## 11. Lugares

### places

- id PK/FK entities.id
- place_type
- description
- latitude NULL
- longitude NULL
- geometry futura
- valid_from NULL
- valid_to NULL

### place_names

- id
- place_id
- name
- language_id NULL
- name_type
- valid_from NULL
- valid_to NULL
- source_id NULL

Un Place puede tener muchos nombres históricos y modernos.

PostGIS queda reservado para una migración posterior.

---

## 12. Períodos y dataciones

### periods

- id PK/FK entities.id
- name
- earliest NULL
- latest NULL
- description

### dating_assertions

- id
- entity_id
- earliest
- latest
- precision
- dating_method
- confidence_id
- claimant_person_id NULL
- notes
- created_at

### dating_assertion_sources

- dating_assertion_id
- source_id
- source_location_id NULL

Una entidad puede tener múltiples DatingAssertions.

No existe una única fecha obligatoria.

---

## 13. Fuentes

### sources

- id PK/FK entities.id
- source_type
- title
- author_text
- publisher
- publication_year
- isbn NULL
- doi NULL
- url NULL
- accessed_at NULL
- notes

### source_locations

- id
- source_id
- page NULL
- volume NULL
- chapter NULL
- section NULL
- paragraph NULL
- line NULL
- figure NULL
- table NULL
- locator_text NULL
- url NULL

Una Source puede tener múltiples localizadores.

---

## 14. Evidencia

### evidence

- id PK/FK entities.id
- evidence_type
- description
- observation
- confidence_id NULL
- created_by_user_id NULL
- created_at
- updated_at

### evidence_sources

- evidence_id
- source_id
- source_location_id NULL

### evidence_entities

- evidence_id
- entity_id
- role

Esto permite asociar una evidencia con varias entidades sin imponer una dirección artificial.

---

## 15. Claims

### claims

- id PK/FK entities.id
- subject_entity_id
- predicate
- object_entity_id NULL
- value_text NULL
- value_number NULL
- value_date NULL
- value_json NULL
- confidence_id
- claimant_person_id NULL
- status
- notes
- created_at
- updated_at

Regla:

Un Claim debe tener un objeto entidad o un valor, pero no necesariamente ambos.

Ejemplos:

`Genesis --composed_in--> Ancient Israel`

`Work --dated_to--> Period`

`Person --attributed_as_author_of--> Work`

`Claim --has_value--> "..." `

### claim_sources

- claim_id
- source_id
- source_location_id NULL

### claim_evidence

- claim_id
- evidence_id

---

## 16. Interpretaciones

### interpretations

- id PK/FK entities.id
- title
- statement
- confidence_id
- claimant_person_id NULL
- status
- notes
- created_at
- updated_at

### interpretation_evidence

- interpretation_id
- evidence_id

### interpretation_claims

- interpretation_id
- claim_id

### interpretation_sources

- interpretation_id
- source_id
- source_location_id NULL

### interpretation_alternatives

- interpretation_id
- alternative_interpretation_id

La relación alternativa es autorreferencial y debe impedir `id = alternative_interpretation_id`.

---

## 17. Hipótesis

### hypotheses

- id PK/FK entities.id
- statement
- confidence_id
- claimant_person_id NULL
- status
- notes
- created_at
- updated_at

### hypothesis_evidence

- hypothesis_id
- evidence_id

### hypothesis_claims

- hypothesis_id
- claim_id

### hypothesis_interpretations

- hypothesis_id
- interpretation_id

### hypothesis_sources

- hypothesis_id
- source_id
- source_location_id NULL

Una hipótesis puede depender de varias interpretaciones.

---

## 18. Relations

### relations

- id PK/FK entities.id
- subject_entity_id
- predicate
- object_entity_id
- confidence_id
- temporal_context NULL
- notes
- status
- created_at
- updated_at

### relation_sources

- relation_id
- source_id
- source_location_id NULL

### relation_evidence

- relation_id
- evidence_id

Las relaciones son claims binarios especializados.

Predicados iniciales:

- parallel
- antecedent
- contact
- influence
- dependence
- reinterpretation
- syncretism
- translation
- inheritance
- reaction
- related_to

Una relación `influence` con confidence `plausible` no equivale a dependencia demostrada.

---

## 19. Conceptos

### concepts

- id PK/FK entities.id
- name
- description
- concept_type

### concept_relations

- concept_id
- related_concept_id
- relation_type
- confidence_id
- source_id NULL

---

## 20. Confianza

### confidence_levels

- id
- key
- label
- description
- ordinal NULL

Valores iniciales:

- documented
- strongly_supported
- plausible
- possible
- unsupported

El ordinal es solamente para ordenamiento interno y no debe mostrarse como una puntuación.

---

## 21. Usuarios y control editorial

### users

- id
- email
- display_name
- status
- created_at
- updated_at

### roles

- id
- key
- name

### user_roles

- user_id
- role_id

Roles iniciales:

- registered_user
- contributor
- editor
- administrator

### contributions

- id
- submitted_by_user_id
- entity_id NULL
- contribution_type
- proposed_content
- reason
- status
- created_at
- updated_at

### contribution_sources

- contribution_id
- source_id
- source_location_id NULL

### reviews

- id
- contribution_id
- reviewer_user_id
- decision
- comment
- created_at

Decisiones:

- pending
- needs_revision
- approved
- rejected

### revisions

- id
- entity_id
- contribution_id NULL
- created_by_user_id
- previous_revision_id NULL
- revision_number
- content
- created_at

### publications

- id
- entity_id
- revision_id
- published_by_user_id
- published_at

Regla crítica:

Una Contribution nunca altera directamente una entidad publicada.

---

## 22. Versionado de contenido textual/editorial

Las entidades cuyo contenido sea editorialmente mutable deben utilizar revisiones.

El patrón general es:

`current published state ← Publication ← Revision ← Contribution`

El historial nunca se elimina físicamente.

---

## 23. Cardinalidades principales

### Biblioteca

- Tradition 1:N Work
- Work 1:N TextualWitness
- Manuscript N:M TextualWitness
- Edition N:M TextualWitness
- Translation N:M Edition/TextualWitness
- TextualWitness 1:N TextualUnit
- TextualUnit 1:N TextualUnit mediante parent_id

### Contexto

- Person N:M Work mediante PersonWorkRole
- Place 1:N PlaceName
- Entity 1:N DatingAssertion
- Source 1:N SourceLocation
- Evidence N:M Source
- Claim N:M Evidence
- Claim N:M Source
- Interpretation N:M Claim/Evidence/Source
- Hypothesis N:M Interpretation/Claim/Evidence/Source

### Grafo

- Entity 1:N Claims como sujeto
- Entity 1:N Claims como objeto
- Entity N:M Entity mediante Relations

### Editorial

- User N:M Role
- User 1:N Contribution
- Contribution 1:N Review
- Contribution 1:N Revision
- Entity 1:N Revision
- Revision 1:0..1 Publication

---

## 24. Índices esenciales

Crear índices para:

- entities(entity_type)
- entities(entity_type, stable_key)
- works(tradition_id)
- textual_witnesses(work_id)
- textual_witnesses(language_id)
- manuscripts(findspot_id)
- manuscripts(current_location_id)
- textual_units(parent_id)
- textual_units(witness_id)
- textual_units(translation_id)
- place_names(place_id)
- dating_assertions(entity_id)
- dating_assertions(confidence_id)
- source_locations(source_id)
- evidence_sources(source_id)
- evidence_entities(entity_id)
- claims(subject_entity_id)
- claims(object_entity_id)
- claims(predicate)
- claim_sources(source_id)
- claim_evidence(evidence_id)
- relations(subject_entity_id)
- relations(object_entity_id)
- relations(predicate)
- relation_sources(source_id)
- contribution(status)
- review(contribution_id, created_at)
- revision(entity_id, revision_number)
- publication(entity_id)

Las búsquedas de texto completo se diseñarán después de conocer el corpus real.

---

## 25. Restricciones que deben existir en PostgreSQL

1. PK/FK para todas las relaciones internas.
2. UNIQUE para claves estables.
3. CHECK para estados y tipos controlados cuando no necesitemos tablas de referencia.
4. CHECK para impedir valores históricos imposibles cuando el modelo lo permita.
5. CHECK para translation_sources: al menos edition_id o witness_id.
6. CHECK para claims: object_entity_id o al menos un value_*.
7. CHECK para relations: subject_entity_id <> object_entity_id cuando el predicado no admita reflexividad.
8. CHECK para interpretation_alternatives: interpretation_id <> alternative_interpretation_id.
9. UNIQUE en tablas puente cuando la relación no pueda repetirse.
10. No usar CASCADE destructivo sobre historial editorial.
11. Preferir RESTRICT para registros históricos.
12. Las eliminaciones físicas deben ser excepcionales; el contenido publicado debe poder conservar su historial.

---

## 26. Decisiones deliberadamente pospuestas

No incluir todavía:

- PostGIS;
- motor de búsqueda especializado;
- variantes textuales completas;
- almacenamiento de facsímiles;
- rutas geográficas avanzadas;
- arqueological_site como entidad separada;
- microservicios;
- sistema de puntuación de evidencia.

Estas capacidades no deben bloquear el esquema inicial.

## 27. Regla de oro del esquema

La base de datos debe poder responder por separado:

1. ¿Qué texto tenemos?
2. ¿Qué testimonio lo conserva?
3. ¿Dónde está físicamente?
4. ¿Qué edición utilizamos?
5. ¿Qué traducción estamos mostrando?
6. ¿Qué evidencia existe?
7. ¿Quién afirma qué?
8. ¿Qué interpretación se propone?
9. ¿Qué hipótesis se plantea?
10. ¿Qué relación entre tradiciones se propone?
11. ¿Qué fuente respalda cada afirmación?
12. ¿Quién modificó el registro y quién autorizó su publicación?

Si una migración impide responder alguna de estas preguntas, el modelo todavía no está listo.

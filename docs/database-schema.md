# Esquema relacional PostgreSQL — diseño v1.1

Este documento convierte el modelo conceptual v2 en tablas, cardinalidades, claves e índices. No constituye todavía una migración ejecutable.

## Convenciones

- PostgreSQL.
- UUID como identificador técnico de entidades y registros.
- `created_at` y `updated_at` en entidades mutables.
- `stable_key` es único dentro de cada `entity_type`.
- Las fechas históricas no se almacenan como un único campo `date` cuando existe incertidumbre.
- Las relaciones editoriales importantes conservan provenance.
- Los nombres visibles no son claves primarias.

## 1. Registro transversal

### entities

| Campo | Tipo conceptual | Restricción |
|---|---|---|
| id | uuid | PK |
| entity_type | text | NOT NULL |
| stable_key | text | NOT NULL |
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

### work_traditions

- work_id FK works.id
- tradition_id FK traditions.id
- relationship_type NULL
- confidence_id NULL
- source_id NULL
- notes NULL
- UNIQUE(work_id, tradition_id)

Se utiliza N:M desde el inicio. Una obra puede estar vinculada a varias tradiciones y una tradición puede contener múltiples obras.

---

## 3. Obras

### works

| Campo | Tipo | Restricción |
|---|---|---|
| id | uuid | PK/FK entities.id |
| title | text | NOT NULL |
| description | text | NULL |
| status | text | NOT NULL |
| created_at | timestamptz | NOT NULL |
| updated_at | timestamptz | NOT NULL |

No existe `author_id` ni `tradition_id`.

Una obra puede tener múltiples autores/atribuciones mediante `person_work_roles`.

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
- UNIQUE(edition_id, witness_id)

Una edición puede utilizar múltiples testimonios.

---

## 7. Traducciones

### translations

| Campo | Tipo |
|---|---|
| id | uuid PK/FK entities.id |
| title | text NOT NULL |
| target_language_id | uuid FK languages.id NOT NULL |
| translator_notes | text NULL |
| publication_year | integer NULL |
| description | text NULL |

### translation_sources

- translation_id
- edition_id NULL
- witness_id NULL
- source_type NOT NULL
- notes

Restricción:

- Al menos uno de `edition_id` o `witness_id` debe estar presente.
- Ambos pueden estar presentes cuando se documenta una traducción que declara utilizar una edición basada en determinados testimonios.

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

Restricción:

- `witness_id` o `translation_id` debe estar presente.
- Ambos pueden estar presentes cuando la unidad representa una alineación explícita entre testimonio y traducción.

La jerarquía se obtiene mediante `parent_id`.

Ejemplos:

- libro → capítulo → verso
- canto → línea
- logion
- inscripción → línea

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
- UNIQUE(language_id, script_id)

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
- UNIQUE(person_id, work_id, role)

Esto permite distinguir autor, atribución tradicional, compilador, traductor, escriba, redactor, editor, investigador y descubridor.

---

## 11. Lugares

### places

- id PK/FK entities.id
- place_type
- description
- latitude NULL
- longitude NULL
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
- UNIQUE(dating_assertion_id, source_id, source_location_id)

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
- UNIQUE(evidence_id, source_id, source_location_id)

### evidence_entities

- evidence_id
- entity_id
- role
- UNIQUE(evidence_id, entity_id, role)

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

Modelo:

`subject --predicate--> object`

o

`subject --predicate--> literal`

Restricciones:

1. Debe existir `object_entity_id` o exactamente uno de los campos `value_*`.
2. No se permite simultáneamente un objeto entidad y un literal.
3. Entre `value_text`, `value_number`, `value_date` y `value_json` solamente uno puede estar presente.

Ejemplos:

`Work --dated_to--> Period`

`Person --attributed_as_author_of--> Work`

`Work --has_title_variant--> "..." `

### claim_sources

- claim_id
- source_id
- source_location_id NULL
- UNIQUE(claim_id, source_id, source_location_id)

### claim_evidence

- claim_id
- evidence_id
- UNIQUE(claim_id, evidence_id)

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
- UNIQUE(interpretation_id, evidence_id)

### interpretation_claims

- interpretation_id
- claim_id
- UNIQUE(interpretation_id, claim_id)

### interpretation_sources

- interpretation_id
- source_id
- source_location_id NULL
- UNIQUE(interpretation_id, source_id, source_location_id)

### interpretation_alternatives

- interpretation_id
- alternative_interpretation_id
- CHECK(interpretation_id <> alternative_interpretation_id)
- UNIQUE(interpretation_id, alternative_interpretation_id)

La relación alternativa es autorreferencial.

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
- UNIQUE(hypothesis_id, evidence_id)

### hypothesis_claims

- hypothesis_id
- claim_id
- UNIQUE(hypothesis_id, claim_id)

### hypothesis_interpretations

- hypothesis_id
- interpretation_id
- UNIQUE(hypothesis_id, interpretation_id)

### hypothesis_sources

- hypothesis_id
- source_id
- source_location_id NULL
- UNIQUE(hypothesis_id, source_id, source_location_id)

Una hipótesis puede depender de varias interpretaciones, claims y evidencias.

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
- UNIQUE(relation_id, source_id, source_location_id)

### relation_evidence

- relation_id
- evidence_id
- UNIQUE(relation_id, evidence_id)

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
- UNIQUE(concept_id, related_concept_id, relation_type)

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

`email` debe ser UNIQUE.

### roles

- id
- key
- name
- UNIQUE(key)

### user_roles

- user_id
- role_id
- UNIQUE(user_id, role_id)

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
- UNIQUE(contribution_id, source_id, source_location_id)

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
- content_jsonb
- created_at

UNIQUE(entity_id, revision_number)

El contenido se conserva como snapshot estructurado para permitir que diferentes tipos de entidad tengan esquemas de contenido distintos.

### publications

- id
- entity_id
- revision_id
- published_by_user_id
- published_at

Una entidad puede tener múltiples publicaciones históricas y una revisión puede estar publicada más de una vez si el flujo editorial lo requiere.

La publicación es un evento, no el estado actual.

Regla crítica:

Una Contribution nunca altera directamente una entidad publicada.

---

## 22. Versionado de contenido textual/editorial

El patrón general es:

`current published state ← Publication ← Revision ← Contribution`

El historial nunca se elimina físicamente.

Una entidad puede tener múltiples revisiones y múltiples publicaciones.

---

## 23. Cardinalidades principales

### Biblioteca

- Tradition N:M Work mediante WorkTradition
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
- Revision 1:N Publication
- Entity 1:N Publication

---

## 24. Índices esenciales

Crear índices para:

- entities(entity_type)
- entities(entity_type, stable_key)
- works(status)
- work_traditions(tradition_id)
- work_traditions(work_id)
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
- contributions(status)
- reviews(contribution_id, created_at)
- revisions(entity_id, revision_number)
- publications(entity_id, published_at)
- publications(revision_id)

Las búsquedas de texto completo se diseñarán después de conocer el corpus real.

---

## 25. Restricciones que deben existir en PostgreSQL

1. PK/FK para todas las relaciones internas.
2. UNIQUE para claves estables.
3. CHECK para estados y tipos controlados cuando no necesitemos tablas de referencia.
4. CHECK para impedir valores históricos imposibles cuando el modelo lo permita.
5. CHECK para translation_sources: al menos edition_id o witness_id.
6. CHECK para textual_units: witness_id o translation_id.
7. CHECK para claims: exactamente un object_entity_id o un value_*.
8. CHECK para claims: como máximo un value_*.
9. CHECK para interpretation_alternatives: interpretation_id <> alternative_interpretation_id.
10. UNIQUE en tablas puente cuando la relación no pueda repetirse.
11. No usar CASCADE destructivo sobre historial editorial.
12. Preferir RESTRICT para registros históricos.
13. Las eliminaciones físicas deben ser excepcionales.
14. Una publicación debe apuntar siempre a una revisión existente.
15. Una revisión debe apuntar a la entidad que versiona.
16. Una entidad no puede tener dos revisiones con el mismo revision_number.

---

## 26. Decisiones deliberadamente pospuestas

No incluir todavía:

- PostGIS;
- motor de búsqueda especializado;
- variantes textuales completas;
- almacenamiento de facsímiles;
- rutas geográficas avanzadas;
- archaeological_site como entidad separada;
- microservicios;
- sistema de puntuación de evidencia.

Estas capacidades no deben bloquear el esquema inicial.

## 27. Resultado de las pruebas de estrés

### Génesis

Modelo soporta:

- una obra;
- múltiples testimonios;
- múltiples manuscritos;
- múltiples ediciones;
- múltiples traducciones;
- relaciones entre edición y testimonios;
- traducciones basadas en una edición y/o testimonios concretos.

Resultado: PASS.

### Evangelio de Tomás

Modelo soporta:

- un Work;
- testimonio copto;
- fragmentos griegos independientes;
- manuscritos distintos;
- traducción española basada en el testimonio copto;
- futura relación entre testimonios sin confundir Work con Manuscript.

Resultado: PASS.

### Homo naledi

Modelo soporta:

- evidencia material;
- claims descriptivos;
- interpretaciones;
- hipótesis;
- fuentes;
- niveles de confianza;
- separación explícita entre observación e interpretación.

Resultado: PASS.

### Relación de influencia

Modelo soporta:

- sujeto;
- objeto;
- predicado influence;
- evidencia;
- fuentes;
- confidence plausible;
- distinción entre influence y dependence.

Resultado: PASS.

### Prueba negativa: Claim inválido

Debe rechazarse:

`Work --dated_to--> Period + value_text="9600 BCE"`

porque mezcla objeto entidad y literal.

Resultado esperado: REJECT.

### Prueba negativa: unidad textual huérfana

Debe rechazarse:

`TextualUnit(witness_id=NULL, translation_id=NULL)`

porque no identifica qué testimonio/traducción representa.

Resultado esperado: REJECT.

### Prueba negativa: publicación sin revisión

Debe rechazarse:

`Publication(revision_id=NULL)`

porque una publicación debe poder reconstruirse a partir de una revisión concreta.

Resultado esperado: REJECT.

---

## 28. Regla de oro del esquema

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

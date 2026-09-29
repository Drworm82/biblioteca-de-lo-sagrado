# Modelo de datos v2

## Objetivo

El modelo debe representar una biblioteca digital comparada de textos sagrados y religiosos, junto con sus testigos textuales, manuscritos, ediciones, traducciones, fuentes, personas, lugares, conceptos y relaciones.

El modelo debe conservar la incertidumbre histórica y distinguir estrictamente entre evidencia, afirmaciones documentadas, interpretaciones e hipótesis.

Principio central:

> La biblioteca registra primero la evidencia; después las interpretaciones; finalmente las relaciones y reconstrucciones.

La biblioteca no establece un canon religioso ni presupone que una tradición sea verdadera, falsa, original o derivada de otra.

---

## 1. Registro de entidades

Todas las entidades relevantes reciben un identificador estable independiente de su nombre visible.

### Entity

Registro transversal para identificar entidades que pueden participar en el grafo.

Campos conceptuales:

- id
- entity_type
- stable_key
- created_at
- updated_at

El registro no sustituye las tablas de dominio. Sirve como identidad común para relaciones, afirmaciones y consultas.

---

## 2. Tradición

### Tradition

Tradición religiosa, cultural, textual o histórica.

No debe confundirse automáticamente con una religión institucional moderna.

Puede representar, por ejemplo:

- una tradición mesopotámica;
- una tradición textual;
- una tradición budista;
- una tradición cristiana oriental;
- una tradición ritual local.

Las categorías más específicas deben conservarse como metadatos o relaciones, no imponerse en la identidad básica.

---

## 3. Obras y transmisión textual

### Work

Obra o unidad textual identificable como composición, corpus o texto.

Ejemplos:

- Génesis
- Evangelio de Tomás
- Epopeya de Gilgamesh
- Himno a Inanna

Una obra no equivale a un manuscrito concreto.

### TextualWitness

Testimonio textual concreto de una obra o tradición textual.

Puede ser:

- manuscrito;
- fragmento;
- inscripción;
- cita antigua;
- traducción antigua;
- otro testimonio textual identificable.

Un testimonio textual no tiene que ser necesariamente un manuscrito físico.

### Manuscript

Objeto o conjunto físico que conserva uno o varios testimonios.

La distinción fundamental es:

> Manuscript = soporte físico.
>
> TextualWitness = evidencia textual conservada.

Un manuscrito puede contener varias obras o testimonios.

### Edition

Edición editorial de una obra o conjunto de testimonios.

Puede ser:

- edición diplomática;
- edición crítica;
- edición facsimilar;
- edición académica;
- edición popular.

### Translation

Traducción identificable de una obra, testimonio o edición.

Una traducción puede basarse en múltiples fuentes.

### TranslationSource

Relación entre una traducción y sus fuentes de base.

Debe permitir múltiples:

- manuscritos;
- testimonios;
- ediciones;
- textos críticos;
- traducciones anteriores.

Esto evita asumir que toda traducción procede de un único testimonio.

### TextualUnit

Unidad estructural de un texto.

No debe estar diseñada específicamente para la Biblia.

Puede representar:

- libro;
- capítulo;
- verso;
- línea;
- logion;
- canto;
- sección;
- inscripción;
- párrafo;
- otra unidad pertinente.

Debe poder formar jerarquías mediante `parent_id`.

Ejemplos:

`Biblia → Libro → Capítulo → Versículo`

`Evangelio de Tomás → Logion`

`Inscripción → Línea`

### TextualVariant

Modelo futuro para registrar lecturas variantes entre testimonios.

Ejemplo conceptual:

`Unidad textual → Testimonio A → lectura A`
`Unidad textual → Testimonio B → lectura B`

La implementación puede incorporarse después, pero el modelo no debe impedirla.

---

## 4. Lenguas y escritura

### Language

Lengua utilizada por una obra, testimonio, edición o traducción.

### Script

Sistema de escritura utilizado para representar una lengua.

Language y Script son entidades diferentes.

Ejemplo:

Una misma lengua puede aparecer en diferentes sistemas de escritura y un sistema de escritura puede utilizarse para diferentes lenguas.

También deben poder registrarse:

- transliteración;
- normalización;
- nombre original;
- variantes ortográficas.

---

## 5. Personas y roles

### Person

Persona histórica, tradicional o relevante para la transmisión.

No usar `works.author_id`.

### PersonWorkRole

Relaciona una persona con una obra o manifestación mediante un papel explícito.

Roles posibles:

- author
- attributed_author
- traditional_attribution
- compiler
- redactor
- translator
- scribe
- editor
- commentator
- discoverer
- researcher
- other

Las discrepancias sobre autoría se representan mediante Claims y fuentes, no mediante una falsa certeza en Work.

---

## 6. Geografía

### Place

Lugar geográfico histórico o contemporáneo.

Puede representar:

- ciudad;
- región;
- país histórico;
- asentamiento;
- sitio arqueológico;
- cueva;
- montaña;
- río;
- isla;
- templo;
- santuario;
- lugar de hallazgo;
- otro lugar pertinente.

No limitar Place a un simple punto geográfico.

### PlaceName

Nombre de un lugar, con posibilidad de registrar:

- nombre;
- lengua;
- período de uso;
- tipo;
- nombre histórico;
- nombre moderno;
- fuente.

Una frontera moderna no debe asumirse automáticamente como una frontera histórica.

Las geometrías complejas y PostGIS pueden incorporarse posteriormente.

---

## 7. Cronología

### Period

Período histórico o rango cronológico.

No representa necesariamente una fecha exacta.

### DatingAssertion

Propuesta de datación aplicada a una entidad.

Debe permitir múltiples propuestas simultáneas:

- entity_id
- earliest
- latest
- preferred
- precision
- dating_method
- source_ids
- confidence
- notes

Una fecha publicada por un investigador no debe convertirse automáticamente en la única fecha verdadera del registro.

Ejemplo:

Una obra puede tener tres propuestas académicas de datación, cada una con sus fuentes y grado de confianza.

---

## 8. Fuentes

### Source

Fuente bibliográfica, arqueológica, epigráfica, manuscrita, institucional o académica.

### SourceLocation

Localización precisa dentro de una fuente.

Puede contener:

- página;
- volumen;
- capítulo;
- sección;
- párrafo;
- línea;
- figura;
- tabla;
- URL;
- DOI;
- identificador externo;
- locator_text.

Una afirmación importante debe poder señalar exactamente dónde se encuentra el respaldo.

---

## 9. Evidencia, afirmaciones e interpretación

Este es uno de los componentes centrales del proyecto.

### Evidence

Registro de evidencia observable o documentada.

Puede ser:

- arqueológica;
- textual;
- lingüística;
- epigráfica;
- paleográfica;
- histórica;
- geográfica;
- antropológica;
- científica;
- material.

Evidence debe describir aquello que puede respaldarse directamente.

Ejemplo:

> Se encontraron restos humanos en una cámara profunda del sistema Rising Star.

No debe incorporar automáticamente una conclusión religiosa.

### Claim

Afirmación estructurada sobre una entidad o conjunto de entidades.

Puede expresar:

- composición;
- procedencia;
- autoría;
- datación;
- contenido;
- existencia;
- relación;
- interpretación;
- estado de investigación.

Una Claim puede tener:

- subject_entity;
- predicate;
- object_entity o valor;
- source_ids;
- evidence_ids;
- confidence;
- claimant;
- date;
- notes.

### Interpretation

Interpretación explícita de una evidencia o conjunto de Claims.

Debe conservar:

- quién la propone;
- fuentes;
- evidencia utilizada;
- fecha o versión;
- grado de confianza;
- interpretaciones alternativas.

### Hypothesis

Propuesta explicativa que va más allá de lo directamente demostrado.

Una hipótesis puede ser perfectamente legítima dentro de la biblioteca, pero debe estar identificada como tal.

### Regla

No convertir automáticamente:

`Evidence → Claim factual fuerte`

ni:

`Evidence → religión`

La transición debe quedar explícita.

---

## 10. Prehistoria y arqueología del comportamiento religioso

El modelo debe poder estudiar el origen de prácticas relacionadas con la muerte y el simbolismo sin asumir que toda conducta simbólica constituye una religión.

Ejemplo de progresión analítica:

1. restos humanos;
2. disposición del cadáver;
3. tratamiento diferencial;
4. entierro intencional;
5. práctica mortuoria;
6. repetición o estructuración de prácticas;
7. simbolismo asociado;
8. posible ritualización;
9. religiosidad o sistema ritual;
10. organización religiosa;
11. institucionalización religiosa.

Estos niveles no son una escala universal ni una cronología obligatoria. Son categorías analíticas.

### Homo naledi como caso de prueba

La información debe poder representarse así:

`Evidence`
→ restos humanos y distribución espacial

`Claim`
→ los restos presentan una distribución que requiere explicación

`Interpretation`
→ posible transporte o depósito intencional

`Hypothesis`
→ posible comportamiento mortuorio socialmente elaborado

No debe almacenarse automáticamente:

> Homo naledi tenía una religión o creía en una vida después de la muerte.

La biblioteca puede registrar esas interpretaciones si existen investigadores que las hayan propuesto, pero debe atribuirlas y conservar su carácter hipotético.

El mismo principio se aplica a:

- Shanidar;
- Tinshemet;
- Chauvet;
- Göbekli Tepe;
- arte rupestre;
- pigmentos;
- objetos funerarios;
- paisajes rituales.

---

## 11. Relations

### Principio

Una relación entre dos entidades es una afirmación estructurada, no una verdad implícita.

Relaciones iniciales:

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

Una relación debe poder almacenar:

- subject_entity;
- predicate;
- object_entity;
- confidence;
- source_ids;
- evidence_ids;
- claimant;
- notes;
- temporal context.

Por tanto:

`Tradition A --influence--> Tradition B`

no significa automáticamente que la influencia esté demostrada.

Puede tener:

`confidence = plausible`

y una o varias fuentes.

### Relación vs Claim

Las relaciones son una especialización semántica de Claims entre entidades.

Esto evita crear una tabla distinta para cada tipo de relación histórica.

Una arquitectura inicial puede mantener una tabla especializada `relations` por claridad de consulta, pero conceptualmente debe conservar el mismo principio de provenance y evidencia que una Claim.

---

## 12. Niveles de confianza

Los niveles expresan el estado de la evidencia, no el valor de una tradición.

Valores iniciales:

- documented
- strongly_supported
- plausible
- possible
- unsupported

No utilizar estos valores como puntuaciones.

Una relación `possible` no significa que una tradición sea menos importante; significa que esa relación concreta no está demostrada.

---

## 13. Proveniencia

Toda información editorial importante debe poder responder:

- ¿Qué se afirma?
- ¿Quién lo afirma?
- ¿En qué fuente?
- ¿Dónde exactamente?
- ¿Qué evidencia lo respalda?
- ¿Cuándo se registró?
- ¿Qué edición o versión se utilizó?
- ¿Cuál es el nivel de confianza?
- ¿Existen interpretaciones alternativas?

La procedencia debe ser trazable hasta la fuente.

---

## 14. Edición colaborativa y control editorial

La biblioteca será colaborativa, pero no un wiki de publicación inmediata.

### User

Usuario registrado.

### Role

Rol editorial o de participación.

Roles iniciales:

- visitor
- registered_user
- contributor
- editor
- administrator

### Contribution

Propuesta de modificación o adición.

Puede incluir:

- autor;
- entidad afectada;
- contenido propuesto;
- motivo;
- fuentes;
- evidencia;
- fecha;
- estado.

### Revision

Versión concreta de contenido o dato.

Debe conservar:

- quién realizó el cambio;
- cuándo;
- qué cambió;
- versión anterior;
- versión nueva.

### Review

Evaluación editorial de una Contribution.

Estados posibles:

- pending
- needs_revision
- approved
- rejected

### Publication

Indica qué revisión está publicada.

Regla fundamental:

> Una contribución externa no modifica directamente el contenido publicado.

Inicialmente, el administrador puede ser el único responsable de aprobar cambios. Posteriormente puede delegarse la revisión en editores.

Las propuestas rechazadas deben conservarse en el historial editorial, aunque no sean visibles como contenido público.

---

## 15. Versionado

Los datos y contenidos importantes deben ser versionables.

Nunca depender exclusivamente de sobrescribir el valor anterior.

El sistema debe permitir reconstruir:

`versión anterior → propuesta → revisión → decisión → versión publicada`

Esto es especialmente importante para:

- traducciones;
- notas filológicas;
- interpretaciones;
- relaciones;
- dataciones;
- afirmaciones controvertidas.

---

## 16. Separación fundamental del dominio textual

Nunca tratar como equivalentes:

`Work → TextualWitness → Manuscript → Edition → Translation`

Cada nivel responde a una pregunta diferente:

- Work: ¿qué composición identificamos?
- TextualWitness: ¿qué testimonio concreto tenemos?
- Manuscript: ¿en qué soporte físico se conserva?
- Edition: ¿cómo fue editado/publicado?
- Translation: ¿cómo fue traducido?

Esto permite distinguir correctamente entre:

- original perdido;
- manuscrito conservado;
- fragmento;
- traducción antigua;
- edición crítica;
- traducción moderna.

---

## 17. Principios de implementación

Antes de crear PostgreSQL:

1. validar este modelo contra casos reales;
2. identificar relaciones ambiguas;
3. comprobar claves y cardinalidades;
4. definir restricciones;
5. diseñar índices;
6. diseñar migraciones;
7. implementar el esquema en PostgreSQL/Drizzle.

La base de datos no debe obligar al contenido histórico a ser más preciso de lo que permiten las fuentes.

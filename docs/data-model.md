# Modelo de datos

## Entidades principales

### Tradition

Tradición religiosa, cultural o textual. No equivale necesariamente a una religión institucional moderna.

### Work

Obra identificable como unidad textual o corpus.

### TextualWitness

Testimonio textual concreto, incluyendo manuscrito o testimonio transmitido cuando sea necesario.

### Manuscript

Objeto manuscrito físico o conjunto manuscrito identificable.

### Edition

Edición académica o editorial de un testimonio/texto.

### Translation

Traducción identificable a partir de una obra, testimonio o edición.

### Language

Lengua del texto, manuscrito, edición o traducción.

### Person

Autor, atribuido, traductor, escriba, descubridor, investigador u otra persona relevante.

### Place

Lugar geográfico. Debe poder distinguirse entre nombre histórico y nombre moderno.

### Period

Periodo histórico o rango cronológico.

### Source

Fuente bibliográfica, arqueológica, epigráfica, manuscrita, institucional o académica.

### Claim

Afirmación concreta que puede vincularse a una o más fuentes.

### Relation

Relación entre dos entidades, con tipo, evidencia y grado de confianza.

### Concept

Concepto, motivo o tema que puede aparecer en varias tradiciones.

## Identificadores

Cada entidad tendrá un identificador estable e independiente de su nombre visible.

Ejemplo:

`work-genesis`

El nombre mostrado puede cambiar sin romper las relaciones internas.

## Cronología

No se debe almacenar una única fecha numérica cuando la evidencia proporciona un rango.

Modelo conceptual:

- earliest
- latest
- preferred
- precision
- dating_method
- source_ids

Las fechas BCE se representan internamente con una convención única y se formatean en la interfaz.

## Relaciones

Una relación no significa automáticamente influencia.

Tipos iniciales:

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

Cada relación debe poder almacenar:

- source_entity
- target_entity
- relation_type
- confidence
- source_ids
- note

## Confianza

Valores iniciales:

- documented
- strongly_supported
- plausible
- possible
- unsupported

Estos valores describen el estado de la evidencia, no una valoración de la tradición.

## Geografía

Un Place puede tener:

- coordenadas
- nombre actual
- nombres históricos
- regiones históricas
- periodos de validez
- relaciones con otros lugares

No se debe asumir que una frontera moderna representa una frontera histórica.

## Evidencia prehistórica

La evidencia arqueológica se modela independientemente de cualquier reconstrucción religiosa.

Tipos iniciales:

- burial
- pigment
- cave_art
- architecture
- object
- landscape
- inscription
- settlement

Flujo metodológico:

Evidencia → interpretación identificada → hipótesis, si corresponde.

No se debe convertir automáticamente una evidencia material en una afirmación sobre una religión concreta.

## Proveniencia

Los datos importantes deben poder responder:

- ¿qué se afirma?
- ¿quién lo afirma?
- ¿en qué fuente?
- ¿qué edición o versión?
- ¿en qué ubicación de la fuente?
- ¿qué nivel de confianza tiene?

## Separación textual

Nunca tratar como equivalentes:

Work → TextualWitness → Edition → Translation

Esto permitirá comparar:

- texto original/transmitido
- manuscritos
- variantes
- ediciones críticas
- traducciones históricas
- traducciones modernas

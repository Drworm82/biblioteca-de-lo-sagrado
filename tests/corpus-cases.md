# Corpus de pruebas arquitectónicas

Estos casos son **fixtures de diseño**, no entradas editoriales definitivas. Sirven para intentar romper el modelo antes de cargar el corpus real.

## Caso 1 — Génesis: cadena textual completa

Debe poder representar:

`Work → Tradition → TextualWitness → Manuscript → Edition → Translation`

Y además permitir que una obra tenga varios testigos y que un testigo sea fragmentario.

**Falla que buscamos:** confundir obra, manuscrito y edición; o asumir que existe un único texto material.

## Caso 2 — Mateo 24:3: variantes y traducción

Debe poder representar una unidad textual con:

- lengua original;
- transliteración como contenido derivado;
- una o más lecturas de testigos;
- traducciones diferentes;
- fuentes y localizadores para las decisiones editoriales.

**Falla que buscamos:** almacenar una traducción como si fuera el original o sobrescribir una lectura con otra.

## Caso 3 — Evangelio de Tomás: transmisión indirecta

Debe poder representar una obra cuyo testimonio conservado principal es una traducción antigua y, cuando corresponda, otros fragmentos o testigos relacionados.

**Falla que buscamos:** exigir un manuscrito del supuesto original para que una obra pueda existir en el catálogo.

## Caso 4 — Diluvio: comparación sin dependencia automática

Debe poder relacionar tradiciones y obras mediante:

- parallel;
- antecedent;
- contact;
- influence;
- dependence;

manteniendo por separado confianza, fuentes y evidencia.

La comparación académica del diluvio en Génesis con las tradiciones mesopotámicas muestra precisamente por qué no basta con contar semejanzas: deben evaluarse diferencias, contextos y posibles mecanismos de transmisión. [Oxford Academic, John Day, 2013]

**Falla que buscamos:** que una semejanza cree automáticamente una relación de dependencia.

## Caso 5 — Homo naledi: evidencia → hipótesis

Debe poder almacenar una cadena donde la evidencia arqueológica no sea convertida automáticamente en una afirmación religiosa:

`Evidence → Claim → Interpretation → Hypothesis`

La investigación sobre Rising Star ha presentado evidencia compatible con enterramiento cultural y comportamiento mortuorio; la base debe poder registrar esa interpretación y sus fuentes sin convertirla en una afirmación sobre una religión o una creencia de Homo naledi. [Berger et al., eLife]

**Falla que buscamos:** mezclar observación material, interpretación arqueológica e inferencia sobre creencias.

## Resultado esperado

El esquema pasa la prueba si los cinco casos pueden coexistir sin:

1. duplicar entidades para representar la misma cosa;
2. sobrescribir dataciones o lecturas;
3. perder la procedencia;
4. convertir interpretaciones en hechos;
5. exigir una relación de dependencia donde sólo existe un paralelo;
6. destruir el historial editorial.

-- Biblioteca de lo Sagrado
-- Historical corpus seed fixture v1
-- Five architectural cases: Genesis, Matthew 24:3, Gospel of Thomas,
-- flood traditions, and Homo naledi.
-- This is a test corpus, not a canonical or exhaustive catalog.
-- Historical dates use astronomical_year convention.

BEGIN;

CREATE FUNCTION pg_temp.entity_id(p_type text, p_key text)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM entities WHERE entity_type=p_type AND stable_key=p_key;
  IF v_id IS NULL THEN
    INSERT INTO entities(entity_type,stable_key) VALUES(p_type,p_key) RETURNING id INTO v_id;
  END IF;
  RETURN v_id;
END $$;

-- ---------------------------------------------------------------------------
-- 1. Controlled vocabularies and bibliographic sources
-- ---------------------------------------------------------------------------

INSERT INTO languages(name,iso_639_1,iso_639_3,historical_name,description) VALUES
('Hebrew','he','heb','Hebreo bíblico','Lengua de los testimonios hebreos del corpus.'),
('Ancient Greek','el','grc','Griego antiguo','Lengua de los testimonios griegos.'),
('Coptic',NULL,'cop','Copto','Lengua del testimonio de Nag Hammadi.'),
('Spanish','es','spa','Español','Lengua de trabajo de traducciones propias del corpus.');

INSERT INTO scripts(name,iso_15924,description) VALUES
('Hebrew script','Hebr','Escritura hebrea.'),
('Greek script','Grek','Escritura griega.'),
('Coptic script','Copt','Escritura copta.'),
('Latin script','Latn','Escritura latina.');

INSERT INTO sources(id,source_type,title,author_text,publisher,publication_year,doi,url,notes) VALUES
(pg_temp.entity_id('source','day-2013-genesis-flood'),
 'academic_chapter',
 'Comparative Ancient Near Eastern Study: The Genesis Flood Narrative in Relation to Ancient Near Eastern Flood Accounts',
 'John Day','Oxford University Press',2013,'10.1093/acprof:oso/9780199645534.003.0007',
 'https://academic.oup.com/book/35373/chapter/301258660',
 'Compara Genesis 6–8 con tradiciones mesopotámicas y discute criterios para distinguir paralelos, dependencia directa y dependencia indirecta.'),
(pg_temp.entity_id('source','chen-2013-flood'),
 'academic_monograph',
 'The Primeval Flood Catastrophe: Origins and Early Development in Mesopotamian Traditions',
 'Y. S. Chen','Oxford University Press',2013,'10.1093/acprof:oso/9780199676200.001.0001',
 'https://academic.oup.com/book/8443',
 'Estudio histórico-literario de las tradiciones mesopotámicas del diluvio.'),
(pg_temp.entity_id('source','genesis-dss-commentary'),
 'academic_reference',
 'Genesis 1-11: A New Translation with Introduction and Commentary',
 'Source record for the Dead Sea Scrolls discussion','JSTOR',NULL,NULL,
 'https://www.jstor.org/stable/jj.18137929',
 'La discusión de los manuscritos de Genesis en los Rollos del Mar Muerto sitúa sus testimonios fragmentarios entre la Antigüedad precristiana y los primeros siglos de nuestra era.'),
(pg_temp.entity_id('source','rahlfs-hanhart-2006'),
 'critical_edition',
 'Septuaginta: Id est Vetus Testamentum graece iuxta LXX interpretes. Editio altera',
 'Alfred Rahlfs; Robert Hanhart','Deutsche Bibelgesellschaft',2006,NULL,
 'https://www.die-bibel.de/de/bible-society-and-biblical-studies/scholarly-editions/septuagint/septuaginta-deutsch/wissenschaftliche-ausgaben/septuaginta',
 'Edición revisada de 2006 de la Septuaginta de Rahlfs.'),
(pg_temp.entity_id('source','matthew-24-3-witness-reference'),
 'textual_reference',
 'Matthew 24:3 — Greek textual witnesses',
 'Witness-level reference',NULL,NULL,NULL,
 'https://biblehub.com/texts/matthew/24-3.htm',
 'Referencia de testigos que muestra, entre otros, Codex Sinaiticus, Codex Vaticanus y Codex Ephraemi Syri Rescriptus, además de la variación entre ειπον/ειπε y otros detalles.'),
(pg_temp.entity_id('source','csntm-ga019'),
 'manuscript_catalog',
 'Manuscript GA 019 — Codex Regius',
 'Center for the Study of New Testament Manuscripts',NULL,NULL,NULL,
 'https://manuscripts.csntm.org/manuscript/Group/GA_019',
 'Catálogo del testimonio GA 019 (Codex Regius): códice griego de los Evangelios, fechado en el siglo VIII, Bibliothèque Nationale de France, Gr. 62.'),
(pg_temp.entity_id('source','brill-coptic-gnostic-library'),
 'scholarly_edition',
 'Coptic Gnostic Library Online',
 'Brill','Brill',NULL,NULL,
 'https://scholarlyeditions.brill.com/cglo/',
 'Edición académica digital de los códices de Nag Hammadi; incluye NHC II,2, Gospel of Thomas.'),
(pg_temp.entity_id('source','nasscal-thomas'),
 'scholarly_reference',
 'Gospel of Thomas — e-Clavis Christian Apocrypha',
 'NASSCAL',NULL,NULL,NULL,
 'https://www.nasscal.com/e-clavis-christian-apocrypha/gospel-of-thomas/',
 'Describe el testimonio copto completo y los tres fragmentos griegos de Oxyrhynchus.'),
(pg_temp.entity_id('source','berger-et-al-2025-naledi'),
 'peer_reviewed_article',
 'Evidence for deliberate burial of the dead by Homo naledi',
 'Lee R. Berger et al.','eLife',2025,'10.7554/eLife.89106.3',
 'https://elifesciences.org/articles/89106v1',
 'Versión de registro de 2025. Presenta una hipótesis mínima de enterramiento cultural y recoge desacuerdo de revisión sobre si la conclusión es inequívoca.'),
(pg_temp.entity_id('source','dirks-et-al-2017-naledi-age'),
 'peer_reviewed_article',
 'The age of Homo naledi and associated sediments in the Rising Star Cave, South Africa',
 'Paul H. G. M. Dirks et al.','eLife',2017,'10.7554/eLife.24231',
 'https://doi.org/10.7554/eLife.24231',
 'Establece una edad de deposición de los fósiles de Dinaledi de aproximadamente 236–335 ka.'),
(pg_temp.entity_id('source','berger-et-al-2025-meaning'),
 'peer_reviewed_article',
 'Meaning-making behavior in a small-brained hominin, Homo naledi, from the late Pleistocene: contexts and evolutionary implications',
 'Lee R. Berger et al.','eLife',2025,'10.7554/eLife.89125.3',
 'https://doi.org/10.7554/eLife.89125.3',
 'Discute comportamiento mortuorio y meaning-making como categorías interpretativas; no constituye por sí mismo una prueba de una religión o creencia específica.')
;

INSERT INTO source_locations(source_id,page,chapter,section,locator_text) VALUES
(pg_temp.entity_id('source','day-2013-genesis-flood'),'74–88',NULL,NULL,'Chapter section on Genesis 6–8 and Ancient Near Eastern flood accounts'),
(pg_temp.entity_id('source','chen-2013-flood'),NULL,'Introduction',NULL,'Historical development of Mesopotamian flood traditions'),
(pg_temp.entity_id('source','genesis-dss-commentary'),NULL,NULL,NULL,'Discussion of fragmentary Genesis manuscripts from the Dead Sea Scrolls'),
(pg_temp.entity_id('source','berger-et-al-2025-naledi'),NULL,NULL,'Abstract','Evidence from Dinaledi Chamber, Hill Antechamber and Puzzle Box'),
(pg_temp.entity_id('source','dirks-et-al-2017-naledi-age'),NULL,NULL,'Abstract','Depositional age 236–335 ka'),
(pg_temp.entity_id('source','nasscal-thomas'),NULL,NULL,'Manuscripts','Three Greek fragments and one complete Coptic witness'),
(pg_temp.entity_id('source','csntm-ga019'),NULL,NULL,'Manuscript record','GA 019 / Codex Regius; Gr. 62')
;

INSERT INTO traditions(id,name,description,tradition_type) VALUES
(pg_temp.entity_id('tradition','ancient-israelite-jewish-textual'),'Tradiciones textuales israelitas/judías antiguas','Contextos de transmisión de textos bíblicos hebreos y griegos sin asumir una única forma textual original.','textual'),
(pg_temp.entity_id('tradition','early-christian-gospel'),'Tradiciones cristianas antiguas de evangelios y dichos','Contexto amplio para testimonios griegos y coptos de textos cristianos antiguos.','textual'),
(pg_temp.entity_id('tradition','mesopotamian-flood'),'Tradiciones mesopotámicas del diluvio','Tradiciones literarias mesopotámicas relacionadas con el motivo del diluvio.','comparative'),
(pg_temp.entity_id('tradition','archaeological-mortuary'),'Arqueología del comportamiento mortuorio','Categoría comparativa para evidencia material sobre tratamiento de los muertos.','archaeological')
;

INSERT INTO works(id,title,description,status) VALUES
(pg_temp.entity_id('work','genesis'),'Genesis','Obra bíblica transmitida en múltiples testigos hebreos y griegos.','cataloged'),
(pg_temp.entity_id('work','gospel-of-matthew'),'Gospel of Matthew','Obra cristiana antigua conservada en múltiples testimonios manuscritos y versiones.','cataloged'),
(pg_temp.entity_id('work','gospel-of-thomas'),'Gospel of Thomas','Colección de dichos conservada en un testimonio copto completo y tres fragmentos griegos.','cataloged'),
(pg_temp.entity_id('work','atrahasis'),'Atrahasis','Tradición literaria mesopotámica que contiene un relato del diluvio.','cataloged'),
(pg_temp.entity_id('work','gilgamesh'),'Epic of Gilgamesh','Tradición literaria mesopotámica con un episodio del diluvio en la versión estándar.','cataloged'),
(pg_temp.entity_id('work','babyloniaca'),'Babyloniaca of Berossus','Obra helenística incluida como testimonio comparativo del motivo del diluvio.','cataloged')
;

INSERT INTO work_traditions(work_id,tradition_id,relationship_type,confidence_id,source_id) VALUES
(pg_temp.entity_id('work','genesis'),pg_temp.entity_id('tradition','ancient-israelite-jewish-textual'),'context',(SELECT id FROM confidence_levels WHERE key='documented'),pg_temp.entity_id('source','genesis-dss-commentary')),
(pg_temp.entity_id('work','gospel-of-matthew'),pg_temp.entity_id('tradition','early-christian-gospel'),'context',(SELECT id FROM confidence_levels WHERE key='documented'),pg_temp.entity_id('source','matthew-24-3-witness-reference')),
(pg_temp.entity_id('work','gospel-of-thomas'),pg_temp.entity_id('tradition','early-christian-gospel'),'context',(SELECT id FROM confidence_levels WHERE key='documented'),pg_temp.entity_id('source','nasscal-thomas')),
(pg_temp.entity_id('work','atrahasis'),pg_temp.entity_id('tradition','mesopotamian-flood'),'context',(SELECT id FROM confidence_levels WHERE key='documented'),pg_temp.entity_id('source','chen-2013-flood')),
(pg_temp.entity_id('work','gilgamesh'),pg_temp.entity_id('tradition','mesopotamian-flood'),'context',(SELECT id FROM confidence_levels WHERE key='documented'),pg_temp.entity_id('source','day-2013-genesis-flood')),
(pg_temp.entity_id('work','babyloniaca'),pg_temp.entity_id('tradition','mesopotamian-flood'),'context',(SELECT id FROM confidence_levels WHERE key='documented'),pg_temp.entity_id('source','day-2013-genesis-flood'))
;

-- ---------------------------------------------------------------------------
-- 2. Genesis — full textual chain
-- ---------------------------------------------------------------------------

INSERT INTO textual_witnesses(id,work_id,witness_type,title_or_label,language_id,script_id,date_note,description) VALUES
(pg_temp.entity_id('witness','genesis-4q2'),
 pg_temp.entity_id('work','genesis'),'fragment','4Q2 Genesis',
 (SELECT id FROM languages WHERE iso_639_3='heb'),
 (SELECT id FROM scripts WHERE iso_15924='Hebr'),
 'Qumran manuscript; broad date recorded separately.',
 'Fragmentary Hebrew witness of Genesis from the Dead Sea Scrolls.'),
(pg_temp.entity_id('witness','genesis-lxx'),
 pg_temp.entity_id('work','genesis'),'ancient_translation','Genesis in the Septuagint',
 (SELECT id FROM languages WHERE iso_639_3='grc'),
 (SELECT id FROM scripts WHERE iso_15924='Grek'),
 'Ancient Greek translation tradition; date of individual manuscripts varies.',
 'Greek translation witness, represented here without treating it as the Hebrew composition itself.')
;

INSERT INTO manuscripts(id,repository,shelfmark,material,provenance_note,description) VALUES
(pg_temp.entity_id('manuscript','4q2-genesis'),'Israel Antiquities Authority / Qumran collection','4Q2','parchment','Qumran, Cave 4','Fragmentary Genesis manuscript; associated with the witness 4Q2 Genesis.')
;

INSERT INTO manuscript_witnesses(manuscript_id,witness_id,position_note) VALUES
(pg_temp.entity_id('manuscript','4q2-genesis'),pg_temp.entity_id('witness','genesis-4q2'),'Fragmentary witness.')
;

INSERT INTO editions(id,title,publisher,publication_year,edition_type,source_id) VALUES
(pg_temp.entity_id('edition','rahlfs-hanhart-septuagint'),
 'Septuaginta: Editio altera','Deutsche Bibelgesellschaft',2006,'critical_edition',
 pg_temp.entity_id('source','rahlfs-hanhart-2006'))
;

INSERT INTO edition_witnesses(edition_id,witness_id,role,notes) VALUES
(pg_temp.entity_id('edition','rahlfs-hanhart-septuagint'),pg_temp.entity_id('witness','genesis-lxx'),'base textual tradition','Greek Septuagint edition; individual manuscript witnesses are not collapsed into the work entity.')
;

INSERT INTO translations(id,title,target_language_id,translator_notes,description) VALUES
(pg_temp.entity_id('translation','genesis-working-spanish'),
 'Genesis — traducción de trabajo del corpus',
 (SELECT id FROM languages WHERE iso_639_3='spa'),
 'Traducción propia para pruebas de modelado; no reproduce una traducción editorial comercial.',
 'Objeto de prueba para demostrar que una traducción es derivada y debe conservar sus fuentes base.')
;

INSERT INTO translation_sources(translation_id,edition_id,witness_id,source_type,provenance_role,scope_type,scope_path_key,scope_label,notes) VALUES
(pg_temp.entity_id('translation','genesis-working-spanish'),pg_temp.entity_id('edition','rahlfs-hanhart-septuagint'),NULL,'edition','base_source','passage','genesis.1.1-9','Genesis 1:1–9','Fuente editorial griega usada como base textual de la traducción del pasaje.'),
(pg_temp.entity_id('translation','genesis-working-spanish'),NULL,pg_temp.entity_id('witness','genesis-4q2'),'witness','comparative_witness','passage','genesis.1.1-9','Genesis 1:1–9','Testimonio hebreo fragmentario utilizado como fuente comparativa; no implica que la traducción proceda literalmente de este fragmento.')
;

INSERT INTO textual_units(id,parent_id,witness_id,translation_id,unit_type,label,ordinal,path_key) VALUES
(pg_temp.entity_id('unit','genesis-1-9-4q2'),NULL,pg_temp.entity_id('witness','genesis-4q2'),NULL,'passage','Genesis 1:1–9',1,'genesis.1.1-9'),
(pg_temp.entity_id('unit','genesis-1-9-lxx'),NULL,pg_temp.entity_id('witness','genesis-lxx'),NULL,'passage','Genesis 1:1–9',1,'genesis.1.1-9'),
(pg_temp.entity_id('unit','genesis-working-1-9'),NULL,NULL,pg_temp.entity_id('translation','genesis-working-spanish'),'passage','Genesis 1:1–9',1,'genesis.1.1-9')
;

INSERT INTO dating_assertions(entity_id,earliest,latest,precision,dating_method,confidence_id,notes) VALUES
(pg_temp.entity_id('manuscript','4q2-genesis'),-200,200,'broad_range','paleography and manuscript context',(SELECT id FROM confidence_levels WHERE key='plausible'),'Fixture range intentionally broad; the corpus must permit uncertainty rather than invent a single year.')
;

INSERT INTO dating_assertion_sources(dating_assertion_id,source_id,source_location_id)
SELECT da.id,pg_temp.entity_id('source','genesis-dss-commentary'),
       (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','genesis-dss-commentary') LIMIT 1)
FROM dating_assertions da
WHERE da.entity_id=pg_temp.entity_id('manuscript','4q2-genesis');

-- ---------------------------------------------------------------------------
-- 3. Matthew 24:3 — textual unit and competing readings
-- ---------------------------------------------------------------------------

INSERT INTO textual_witnesses(id,work_id,witness_type,title_or_label,language_id,script_id,date_note,description) VALUES
(pg_temp.entity_id('witness','matthew-sinaiticus-24-3'),pg_temp.entity_id('work','gospel-of-matthew'),'manuscript','Codex Sinaiticus, Matthew 24:3',(SELECT id FROM languages WHERE iso_639_3='grc'),(SELECT id FROM scripts WHERE iso_15924='Grek'),'4th century CE','Greek manuscript witness.'),
(pg_temp.entity_id('witness','matthew-vaticanus-24-3'),pg_temp.entity_id('work','gospel-of-matthew'),'manuscript','Codex Vaticanus, Matthew 24:3',(SELECT id FROM languages WHERE iso_639_3='grc'),(SELECT id FROM scripts WHERE iso_15924='Grek'),'4th century CE','Greek manuscript witness.'),
(pg_temp.entity_id('witness','matthew-ephraemi-24-3'),pg_temp.entity_id('work','gospel-of-matthew'),'manuscript','Codex Ephraemi Syri Rescriptus, Matthew 24:3',(SELECT id FROM languages WHERE iso_639_3='grc'),(SELECT id FROM scripts WHERE iso_15924='Grek'),'5th century CE','Greek manuscript witness.'),
(pg_temp.entity_id('witness','matthew-regius-24-3'),pg_temp.entity_id('work','gospel-of-matthew'),'manuscript','Codex Regius (GA 019), Matthew 24:3',(SELECT id FROM languages WHERE iso_639_3='grc'),(SELECT id FROM scripts WHERE iso_15924='Grek'),'8th century CE','Greek manuscript witness; GA 019, Bibliothèque Nationale de France, Gr. 62.')
;

INSERT INTO textual_units(id,parent_id,witness_id,translation_id,unit_type,label,ordinal,path_key) VALUES
(pg_temp.entity_id('unit','matthew-24-3-sinaiticus'),NULL,pg_temp.entity_id('witness','matthew-sinaiticus-24-3'),NULL,'verse','Matthew 24:3',3,'matthew.24.3'),
(pg_temp.entity_id('unit','matthew-24-3-vaticanus'),NULL,pg_temp.entity_id('witness','matthew-vaticanus-24-3'),NULL,'verse','Matthew 24:3',3,'matthew.24.3'),
(pg_temp.entity_id('unit','matthew-24-3-ephraemi'),NULL,pg_temp.entity_id('witness','matthew-ephraemi-24-3'),NULL,'verse','Matthew 24:3',3,'matthew.24.3'),
(pg_temp.entity_id('unit','matthew-24-3-regius'),NULL,pg_temp.entity_id('witness','matthew-regius-24-3'),NULL,'verse','Matthew 24:3',3,'matthew.24.3')
;

INSERT INTO textual_variants(id,textual_unit_id,variant_type,description,status) VALUES
(pg_temp.entity_id('variant','matthew-24-3-imperative'),pg_temp.entity_id('unit','matthew-24-3-sinaiticus'),'lexical_form','Variation in the imperative form corresponding to ειπον / ειπε.','documented'),
(pg_temp.entity_id('variant','matthew-24-3-autou'),pg_temp.entity_id('unit','matthew-24-3-sinaiticus'),'addition','Some witnesses add αυτου after μαθηται.','documented'),
(pg_temp.entity_id('variant','matthew-24-3-article-kai'),pg_temp.entity_id('unit','matthew-24-3-sinaiticus'),'syntax','Some later textual traditions coordinate the phrases with additional article/conjunction structure.','documented')
;

INSERT INTO textual_variant_readings(id,variant_id,witness_id,textual_unit_id,reading_text,normalized_text,language_id,notes) VALUES
(pg_temp.entity_id('reading','matthew-24-3-sinaiticus-eipe'),pg_temp.entity_id('variant','matthew-24-3-imperative'),pg_temp.entity_id('witness','matthew-sinaiticus-24-3'),pg_temp.entity_id('unit','matthew-24-3-sinaiticus'),'ειπε ημιν','ειπε ημιν',(SELECT id FROM languages WHERE iso_639_3='grc'),'Reading reported for Sinaiticus.'),
(pg_temp.entity_id('reading','matthew-24-3-vaticanus-eipe'),pg_temp.entity_id('variant','matthew-24-3-imperative'),pg_temp.entity_id('witness','matthew-vaticanus-24-3'),pg_temp.entity_id('unit','matthew-24-3-vaticanus'),'ειπε ημιν','ειπε ημιν',(SELECT id FROM languages WHERE iso_639_3='grc'),'Reading reported for Vaticanus.'),
(pg_temp.entity_id('reading','matthew-24-3-ephraemi-eipe'),pg_temp.entity_id('variant','matthew-24-3-imperative'),pg_temp.entity_id('witness','matthew-ephraemi-24-3'),pg_temp.entity_id('unit','matthew-24-3-ephraemi'),'ειπε ημιν','ειπε ημιν',(SELECT id FROM languages WHERE iso_639_3='grc'),'Reading reported for Ephraemi.'),
(pg_temp.entity_id('reading','matthew-24-3-regius-eipon'),pg_temp.entity_id('variant','matthew-24-3-imperative'),pg_temp.entity_id('witness','matthew-regius-24-3'),pg_temp.entity_id('unit','matthew-24-3-regius'),'ειπον ημιν','ειπον ημιν',(SELECT id FROM languages WHERE iso_639_3='grc'),'Reading ειπον reported for GA 019 (Codex Regius); stored separately from the ειπε witnesses.')
;

INSERT INTO textual_variant_sources(variant_id,source_id,source_location_id) VALUES
(pg_temp.entity_id('variant','matthew-24-3-imperative'),pg_temp.entity_id('source','matthew-24-3-witness-reference'),(SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','matthew-24-3-witness-reference') LIMIT 1)),
(pg_temp.entity_id('variant','matthew-24-3-autou'),pg_temp.entity_id('source','matthew-24-3-witness-reference'),(SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','matthew-24-3-witness-reference') LIMIT 1)),
(pg_temp.entity_id('variant','matthew-24-3-article-kai'),pg_temp.entity_id('source','matthew-24-3-witness-reference'),(SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','matthew-24-3-witness-reference') LIMIT 1))
;

INSERT INTO textual_variant_reading_sources(reading_id,source_id,source_location_id)
SELECT r.id,pg_temp.entity_id('source','matthew-24-3-witness-reference'),
       (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','matthew-24-3-witness-reference') LIMIT 1)
FROM textual_variant_readings r
WHERE r.variant_id=pg_temp.entity_id('variant','matthew-24-3-imperative');

INSERT INTO textual_variant_reading_sources(reading_id,source_id,source_location_id)
VALUES(pg_temp.entity_id('reading','matthew-24-3-regius-eipon'),
       pg_temp.entity_id('source','csntm-ga019'), NULL);

INSERT INTO translations(id,title,target_language_id,translator_notes,description) VALUES
(pg_temp.entity_id('translation','matthew-24-3-working-spanish'),
 'Mateo 24:3 — traducción de trabajo del corpus',
 (SELECT id FROM languages WHERE iso_639_3='spa'),
 'Traducción propia para pruebas; debe permanecer vinculada a la unidad textual y no sustituir las lecturas griegas.',
 'Objeto derivado para probar la separación entre texto antiguo y traducción.')
;

INSERT INTO translation_sources(translation_id,witness_id,source_type,provenance_role,scope_type,scope_path_key,scope_label,notes) VALUES
(pg_temp.entity_id('translation','matthew-24-3-working-spanish'),pg_temp.entity_id('witness','matthew-sinaiticus-24-3'),'witness','base_source','passage','matthew.24.3','Mateo 24:3','Base textual de prueba para la traducción de Mateo 24:3.'),
(pg_temp.entity_id('translation','matthew-24-3-working-spanish'),pg_temp.entity_id('witness','matthew-vaticanus-24-3'),'witness','comparative_witness','passage','matthew.24.3','Mateo 24:3','Segunda base textual de prueba utilizada para comparar decisiones de traducción.')
;

-- ---------------------------------------------------------------------------
-- 4. Gospel of Thomas — indirect and multilingual transmission
-- ---------------------------------------------------------------------------

INSERT INTO textual_witnesses(id,work_id,witness_type,title_or_label,language_id,script_id,date_note,description) VALUES
(pg_temp.entity_id('witness','thomas-nhc-ii-2'),pg_temp.entity_id('work','gospel-of-thomas'),'manuscript','Nag Hammadi Codex II, tractate 2 (NHC II,2)',(SELECT id FROM languages WHERE iso_639_3='cop'),(SELECT id FROM scripts WHERE iso_15924='Copt'),'4th century CE','Coptic witness preserving 114 sayings.'),
(pg_temp.entity_id('witness','thomas-poxy-1'),pg_temp.entity_id('work','gospel-of-thomas'),'fragment','P. Oxy. 1',(SELECT id FROM languages WHERE iso_639_3='grc'),(SELECT id FROM scripts WHERE iso_15924='Grek'),'late 2nd/early 3rd century CE','Greek fragment containing portions of sayings 26–33.'),
(pg_temp.entity_id('witness','thomas-poxy-654'),pg_temp.entity_id('work','gospel-of-thomas'),'fragment','P. Oxy. 654',(SELECT id FROM languages WHERE iso_639_3='grc'),(SELECT id FROM scripts WHERE iso_15924='Grek'),'3rd century CE','Greek fragment containing the opening through part of logion 7.'),
(pg_temp.entity_id('witness','thomas-poxy-655'),pg_temp.entity_id('work','gospel-of-thomas'),'fragment','P. Oxy. 655',(SELECT id FROM languages WHERE iso_639_3='grc'),(SELECT id FROM scripts WHERE iso_15924='Grek'),'3rd century CE','Greek fragment containing portions of sayings 24 and 36–39.')
;

INSERT INTO manuscripts(id,repository,shelfmark,material,provenance_note,description) VALUES
(pg_temp.entity_id('manuscript','nhc-ii-2'),'Coptic Museum, Cairo','Inv. 10544 / NHC II,2','papyrus codex','Nag Hammadi, Upper Egypt','Codex II; Gospel of Thomas occupies pages 32–51.'),
(pg_temp.entity_id('manuscript','poxy-1'),'Sackler Library, Oxford','P. Oxy. 1','papyrus','Oxyrhynchus, Egypt','Greek papyrus fragment.'),
(pg_temp.entity_id('manuscript','poxy-654'),'Sackler Library, Oxford','P. Oxy. 654','papyrus','Oxyrhynchus, Egypt','Greek papyrus fragment.'),
(pg_temp.entity_id('manuscript','poxy-655'),'Sackler Library, Oxford','P. Oxy. 655','papyrus','Oxyrhynchus, Egypt','Greek papyrus fragment.')
;

INSERT INTO manuscript_witnesses(manuscript_id,witness_id,position_note) VALUES
(pg_temp.entity_id('manuscript','nhc-ii-2'),pg_temp.entity_id('witness','thomas-nhc-ii-2'),'Complete surviving Coptic witness.'),
(pg_temp.entity_id('manuscript','poxy-1'),pg_temp.entity_id('witness','thomas-poxy-1'),'Fragmentary Greek witness.'),
(pg_temp.entity_id('manuscript','poxy-654'),pg_temp.entity_id('witness','thomas-poxy-654'),'Fragmentary Greek witness.'),
(pg_temp.entity_id('manuscript','poxy-655'),pg_temp.entity_id('witness','thomas-poxy-655'),'Fragmentary Greek witness.')
;

INSERT INTO editions(id,title,publisher,publication_year,edition_type,source_id) VALUES
(pg_temp.entity_id('edition','brill-coptic-thomas'),
 'Coptic Gnostic Library Online — Gospel of Thomas',
 'Brill',NULL,'scholarly_digital_edition',pg_temp.entity_id('source','brill-coptic-gnostic-library'))
;

INSERT INTO edition_witnesses(edition_id,witness_id,role,notes) VALUES
(pg_temp.entity_id('edition','brill-coptic-thomas'),pg_temp.entity_id('witness','thomas-nhc-ii-2'),'primary Coptic witness','Digital scholarly edition.'),
(pg_temp.entity_id('edition','brill-coptic-thomas'),pg_temp.entity_id('witness','thomas-poxy-1'),'Greek comparative witness','Used comparatively; not merged into the Coptic witness.'),
(pg_temp.entity_id('edition','brill-coptic-thomas'),pg_temp.entity_id('witness','thomas-poxy-654'),'Greek comparative witness','Used comparatively.'),
(pg_temp.entity_id('edition','brill-coptic-thomas'),pg_temp.entity_id('witness','thomas-poxy-655'),'Greek comparative witness','Used comparatively.')
;

INSERT INTO textual_units(id,parent_id,witness_id,translation_id,unit_type,label,ordinal,path_key) VALUES
(pg_temp.entity_id('unit','thomas-1-coptic'),NULL,pg_temp.entity_id('witness','thomas-nhc-ii-2'),NULL,'logion','Gospel of Thomas, logion 1',1,'thomas.1'),
(pg_temp.entity_id('unit','thomas-1-greek-fragment'),NULL,pg_temp.entity_id('witness','thomas-poxy-654'),NULL,'fragment','Gospel of Thomas, opening / logia 1–7',1,'thomas.opening-7')
;

INSERT INTO dating_assertions(entity_id,earliest,latest,precision,dating_method,confidence_id,notes) VALUES
(pg_temp.entity_id('manuscript','nhc-ii-2'),300,399,'century','codicology and paleography',(SELECT id FROM confidence_levels WHERE key='documented'),'NHC II is dated to the fourth century in the cited catalog record.'),
(pg_temp.entity_id('manuscript','poxy-654'),200,299,'century','paleography',(SELECT id FROM confidence_levels WHERE key='plausible'),'Fixture follows the cited scholarly reference, which places the fragment in the third century.')
;

INSERT INTO dating_assertion_sources(dating_assertion_id,source_id,source_location_id)
SELECT da.id,pg_temp.entity_id('source','nasscal-thomas'),
       (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','nasscal-thomas') LIMIT 1)
FROM dating_assertions da
WHERE da.entity_id IN (pg_temp.entity_id('manuscript','nhc-ii-2'),pg_temp.entity_id('manuscript','poxy-654'));

-- ---------------------------------------------------------------------------
-- 5. Flood traditions — comparison without automatic dependence
-- ---------------------------------------------------------------------------

INSERT INTO dating_assertions(entity_id,earliest,latest,precision,dating_method,confidence_id,notes) VALUES
(pg_temp.entity_id('work','atrahasis'),-2000,-1600,'period','historical-literary chronology',(SELECT id FROM confidence_levels WHERE key='plausible'),'Represents the Old Babylonian period range discussed by Chen for early/classical flood attestations; not a single composition date.'),
(pg_temp.entity_id('work','gilgamesh'),-1300,-1000,'period','literary chronology',(SELECT id FROM confidence_levels WHERE key='possible'),'Broad fixture range for the Standard Babylonian literary form; not used to assert dependence on Genesis.'),
(pg_temp.entity_id('work','babyloniaca'),-350,-200,'period','historical chronology',(SELECT id FROM confidence_levels WHERE key='possible'),'Broad Hellenistic range for Berossus as a comparative tradition.')
;

INSERT INTO evidence(id,evidence_type,description,observation,confidence_id) VALUES
(pg_temp.entity_id('evidence','flood-shared-motif'),
 'textual_comparison',
 'Comparative scholarship identifies recurring flood-narrative motifs across Genesis and Mesopotamian traditions.',
 'The cited comparative study discusses similarities as well as significant differences among Genesis, Atrahasis, Gilgamesh and Berossus.',
 (SELECT id FROM confidence_levels WHERE key='documented'));

INSERT INTO evidence_sources(evidence_id,source_id,source_location_id)
VALUES(pg_temp.entity_id('evidence','flood-shared-motif'),pg_temp.entity_id('source','day-2013-genesis-flood'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','day-2013-genesis-flood') LIMIT 1));

INSERT INTO evidence_entities(evidence_id,entity_id,role) VALUES
(pg_temp.entity_id('evidence','flood-shared-motif'),pg_temp.entity_id('work','genesis'),'compared_work'),
(pg_temp.entity_id('evidence','flood-shared-motif'),pg_temp.entity_id('work','atrahasis'),'compared_work'),
(pg_temp.entity_id('evidence','flood-shared-motif'),pg_temp.entity_id('work','gilgamesh'),'compared_work'),
(pg_temp.entity_id('evidence','flood-shared-motif'),pg_temp.entity_id('work','babyloniaca'),'compared_work')
;

INSERT INTO relations(id,subject_entity_id,predicate,object_entity_id,confidence_id,temporal_context,status,notes) VALUES
(pg_temp.entity_id('relation','genesis-parallel-atrahasis'),pg_temp.entity_id('work','genesis'),'parallel',pg_temp.entity_id('work','atrahasis'),(SELECT id FROM confidence_levels WHERE key='strongly_supported'),'ancient Near Eastern comparative context','documented','Comparative relationship only; does not by itself assert literary dependence.'),
(pg_temp.entity_id('relation','genesis-parallel-gilgamesh'),pg_temp.entity_id('work','genesis'),'parallel',pg_temp.entity_id('work','gilgamesh'),(SELECT id FROM confidence_levels WHERE key='strongly_supported'),'ancient Near Eastern comparative context','documented','Comparative relationship only.'),
(pg_temp.entity_id('relation','genesis-parallel-berossus'),pg_temp.entity_id('work','genesis'),'parallel',pg_temp.entity_id('work','babyloniaca'),(SELECT id FROM confidence_levels WHERE key='possible'),'Hellenistic and biblical comparative context','documented','Comparative relationship only; chronology and transmission mechanisms require separate analysis.'),
(pg_temp.entity_id('relation','genesis-dependence-atrahasis'),pg_temp.entity_id('work','genesis'),'dependence',pg_temp.entity_id('work','atrahasis'),(SELECT id FROM confidence_levels WHERE key='plausible'),'ancient Near Eastern literary context','hypothesis','Stored as a distinct relation hypothesis, not as a consequence of the parallel relation.')
;

INSERT INTO relation_sources(relation_id,source_id,source_location_id)
SELECT pg_temp.entity_id('relation','genesis-parallel-atrahasis'),pg_temp.entity_id('source','day-2013-genesis-flood'),(SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','day-2013-genesis-flood') LIMIT 1)
UNION ALL
SELECT pg_temp.entity_id('relation','genesis-parallel-gilgamesh'),pg_temp.entity_id('source','day-2013-genesis-flood'),(SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','day-2013-genesis-flood') LIMIT 1)
UNION ALL
SELECT pg_temp.entity_id('relation','genesis-parallel-berossus'),pg_temp.entity_id('source','day-2013-genesis-flood'),(SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','day-2013-genesis-flood') LIMIT 1)
UNION ALL
SELECT pg_temp.entity_id('relation','genesis-dependence-atrahasis'),pg_temp.entity_id('source','day-2013-genesis-flood'),(SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','day-2013-genesis-flood') LIMIT 1)
;

INSERT INTO relation_evidence(relation_id,evidence_id) VALUES
(pg_temp.entity_id('relation','genesis-parallel-atrahasis'),pg_temp.entity_id('evidence','flood-shared-motif')),
(pg_temp.entity_id('relation','genesis-parallel-gilgamesh'),pg_temp.entity_id('evidence','flood-shared-motif')),
(pg_temp.entity_id('relation','genesis-parallel-berossus'),pg_temp.entity_id('evidence','flood-shared-motif')),
(pg_temp.entity_id('relation','genesis-dependence-atrahasis'),pg_temp.entity_id('evidence','flood-shared-motif'))
;

-- ---------------------------------------------------------------------------
-- 6. Homo naledi — evidence -> claim -> interpretation -> hypothesis
-- ---------------------------------------------------------------------------

INSERT INTO places(id,place_type,description,latitude,longitude) VALUES
(pg_temp.entity_id('place','rising-star-cave'), 'archaeological_site',
 'Rising Star cave system, South Africa; Dinaledi Subsystem.',
 -25.928,27.787);

INSERT INTO place_names(place_id,name,name_type) VALUES
(pg_temp.entity_id('place','rising-star-cave'),'Rising Star Cave','modern'),
(pg_temp.entity_id('place','rising-star-cave'),'Dinaledi Subsystem','site_subarea')
;

INSERT INTO works(id,title,description,status) VALUES
(pg_temp.entity_id('work','homo-naledi-mortuary-context'),
 'Homo naledi mortuary context',
 'Catalog entry for the archaeological evidence rather than a textual work.',
 'archaeological_case')
;

INSERT INTO dating_assertions(entity_id,earliest,latest,precision,dating_method,confidence_id,notes) VALUES
(pg_temp.entity_id('work','homo-naledi-mortuary-context'),-335000,-236000,'range','U-Th, US-ESR, OSL and paleomagnetic constraints',(SELECT id FROM confidence_levels WHERE key='strongly_supported'),'The dates refer to the Dinaledi fossil depositional context discussed by Dirks et al.; they do not date every later find in the cave system.')
;

INSERT INTO evidence(id,evidence_type,description,observation,confidence_id) VALUES
(pg_temp.entity_id('evidence','naledi-articulated-remains'),
 'archaeological_observation',
 'Concentrations of Homo naledi remains include articulated, matrix-supported skeletal regions in the Hill Antechamber and Dinaledi Chamber.',
 'The cited study reports spatial positioning and sedimentary context consistent with rapid covering before decomposition.',
 (SELECT id FROM confidence_levels WHERE key='documented')),
(pg_temp.entity_id('evidence','naledi-spatial-sediment'),
 'archaeological_observation',
 'Spatial distribution, topography and sediment observations were used to evaluate alternative depositional explanations.',
 'The study reports that gravity-driven slumping or spontaneous sediment movement did not adequately explain the observed pattern.',
 (SELECT id FROM confidence_levels WHERE key='documented'))
;

INSERT INTO evidence_sources(evidence_id,source_id,source_location_id) VALUES
(pg_temp.entity_id('evidence','naledi-articulated-remains'),pg_temp.entity_id('source','berger-et-al-2025-naledi'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-naledi') LIMIT 1)),
(pg_temp.entity_id('evidence','naledi-spatial-sediment'),pg_temp.entity_id('source','berger-et-al-2025-naledi'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-naledi') LIMIT 1))
;

INSERT INTO evidence_entities(evidence_id,entity_id,role) VALUES
(pg_temp.entity_id('evidence','naledi-articulated-remains'),pg_temp.entity_id('work','homo-naledi-mortuary-context'),'case'),
(pg_temp.entity_id('evidence','naledi-spatial-sediment'),pg_temp.entity_id('work','homo-naledi-mortuary-context'),'case'),
(pg_temp.entity_id('evidence','naledi-spatial-sediment'),pg_temp.entity_id('place','rising-star-cave'),'site')
;

INSERT INTO claims(id,subject_entity_id,predicate,value_text,confidence_id,status,notes) VALUES
(pg_temp.entity_id('claim','naledi-distribution-requires-explanation'),
 pg_temp.entity_id('work','homo-naledi-mortuary-context'),
 'requires_explanation',
 'The spatial and sedimentary distribution of the remains requires an explanation beyond simply assuming ordinary decomposition on the chamber floor.',
 (SELECT id FROM confidence_levels WHERE key='strongly_supported'),
 'documented',
 'This claim summarizes the inferential problem addressed by the cited study; it does not specify a motive.'),
(pg_temp.entity_id('claim','naledi-cultural-burial-compatible'),
 pg_temp.entity_id('work','homo-naledi-mortuary-context'),
 'compatible_with',
 'The evidence is compatible with a minimal hypothesis of cultural burial.',
 (SELECT id FROM confidence_levels WHERE key='plausible'),
 'attributed',
 'Attribution is to Berger et al.; the fixture deliberately does not turn this into a statement about religion or afterlife beliefs.')
;

INSERT INTO claim_sources(claim_id,source_id,source_location_id) VALUES
(pg_temp.entity_id('claim','naledi-distribution-requires-explanation'),pg_temp.entity_id('source','berger-et-al-2025-naledi'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-naledi') LIMIT 1)),
(pg_temp.entity_id('claim','naledi-cultural-burial-compatible'),pg_temp.entity_id('source','berger-et-al-2025-naledi'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-naledi') LIMIT 1))
;

INSERT INTO claim_evidence(claim_id,evidence_id) VALUES
(pg_temp.entity_id('claim','naledi-distribution-requires-explanation'),pg_temp.entity_id('evidence','naledi-articulated-remains')),
(pg_temp.entity_id('claim','naledi-distribution-requires-explanation'),pg_temp.entity_id('evidence','naledi-spatial-sediment')),
(pg_temp.entity_id('claim','naledi-cultural-burial-compatible'),pg_temp.entity_id('evidence','naledi-articulated-remains')),
(pg_temp.entity_id('claim','naledi-cultural-burial-compatible'),pg_temp.entity_id('evidence','naledi-spatial-sediment'))
;

INSERT INTO interpretations(id,title,statement,confidence_id,status,notes) VALUES
(pg_temp.entity_id('interpretation','naledi-mortuary-behavior'),
 'Interpretación arqueológica: comportamiento mortuorio',
 'El patrón de restos y sedimentos puede interpretarse como evidencia de comportamiento mortuorio.',
 (SELECT id FROM confidence_levels WHERE key='plausible'),
 'attributed',
 'No se infiere automáticamente ritual, religión, cosmología ni creencias sobre la muerte.'),
(pg_temp.entity_id('interpretation','naledi-cultural-burial'),
 'Interpretación arqueológica: enterramiento cultural',
 'La hipótesis mínima de enterramiento cultural es una explicación compatible con el conjunto de observaciones publicado.',
 (SELECT id FROM confidence_levels WHERE key='plausible'),
 'attributed',
 'La evaluación editorial de eLife registra también una objeción: la vía exacta por la que los homininos llegaron a la cámara no está completamente establecida.')
;

INSERT INTO interpretation_evidence(interpretation_id,evidence_id) VALUES
(pg_temp.entity_id('interpretation','naledi-mortuary-behavior'),pg_temp.entity_id('evidence','naledi-articulated-remains')),
(pg_temp.entity_id('interpretation','naledi-mortuary-behavior'),pg_temp.entity_id('evidence','naledi-spatial-sediment')),
(pg_temp.entity_id('interpretation','naledi-cultural-burial'),pg_temp.entity_id('evidence','naledi-articulated-remains')),
(pg_temp.entity_id('interpretation','naledi-cultural-burial'),pg_temp.entity_id('evidence','naledi-spatial-sediment'))
;

INSERT INTO interpretation_claims(interpretation_id,claim_id) VALUES
(pg_temp.entity_id('interpretation','naledi-mortuary-behavior'),pg_temp.entity_id('claim','naledi-distribution-requires-explanation')),
(pg_temp.entity_id('interpretation','naledi-cultural-burial'),pg_temp.entity_id('claim','naledi-cultural-burial-compatible'))
;

INSERT INTO interpretation_sources(interpretation_id,source_id,source_location_id) VALUES
(pg_temp.entity_id('interpretation','naledi-mortuary-behavior'),pg_temp.entity_id('source','berger-et-al-2025-meaning'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-meaning') LIMIT 1)),
(pg_temp.entity_id('interpretation','naledi-cultural-burial'),pg_temp.entity_id('source','berger-et-al-2025-naledi'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-naledi') LIMIT 1))
;

INSERT INTO hypotheses(id,statement,confidence_id,status,notes) VALUES
(pg_temp.entity_id('hypothesis','naledi-cultural-burial'),
 'Homo naledi practicó enterramiento cultural de algunos muertos en el sistema Rising Star.',
 (SELECT id FROM confidence_levels WHERE key='plausible'),
 'attributed',
 'Hipótesis mínima atribuida a Berger et al.; no equivale a una afirmación de religión, ritual funerario completo o creencias sobre el más allá.'),
(pg_temp.entity_id('hypothesis','naledi-meaning-making'),
 'El comportamiento mortuorio de Homo naledi puede constituir una forma de comportamiento de creación de significado.',
 (SELECT id FROM confidence_levels WHERE key='possible'),
 'attributed',
 'Hipótesis interpretativa separada del enterramiento como inferencia material.')
;

INSERT INTO hypothesis_evidence(hypothesis_id,evidence_id) VALUES
(pg_temp.entity_id('hypothesis','naledi-cultural-burial'),pg_temp.entity_id('evidence','naledi-articulated-remains')),
(pg_temp.entity_id('hypothesis','naledi-cultural-burial'),pg_temp.entity_id('evidence','naledi-spatial-sediment')),
(pg_temp.entity_id('hypothesis','naledi-meaning-making'),pg_temp.entity_id('evidence','naledi-articulated-remains'))
;

INSERT INTO hypothesis_claims(hypothesis_id,claim_id) VALUES
(pg_temp.entity_id('hypothesis','naledi-cultural-burial'),pg_temp.entity_id('claim','naledi-cultural-burial-compatible')),
(pg_temp.entity_id('hypothesis','naledi-meaning-making'),pg_temp.entity_id('claim','naledi-distribution-requires-explanation'))
;

INSERT INTO hypothesis_interpretations(hypothesis_id,interpretation_id) VALUES
(pg_temp.entity_id('hypothesis','naledi-cultural-burial'),pg_temp.entity_id('interpretation','naledi-cultural-burial')),
(pg_temp.entity_id('hypothesis','naledi-meaning-making'),pg_temp.entity_id('interpretation','naledi-mortuary-behavior'))
;

INSERT INTO hypothesis_sources(hypothesis_id,source_id,source_location_id) VALUES
(pg_temp.entity_id('hypothesis','naledi-cultural-burial'),pg_temp.entity_id('source','berger-et-al-2025-naledi'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-naledi') LIMIT 1)),
(pg_temp.entity_id('hypothesis','naledi-meaning-making'),pg_temp.entity_id('source','berger-et-al-2025-meaning'),
 (SELECT id FROM source_locations WHERE source_id=pg_temp.entity_id('source','berger-et-al-2025-meaning') LIMIT 1))
;

COMMIT;

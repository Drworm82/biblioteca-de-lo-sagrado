-- Biblioteca de lo Sagrado
-- Historical corpus seed fixture v1
-- Scope: five architectural cases from tests/corpus-cases.md.
-- This is a controlled seed/test corpus, not a claim that every field is exhaustive.
-- Historical dates use astronomical_year convention where supplied.

BEGIN;

CREATE TEMP FUNCTION entity_id(p_type text, p_key text)
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

-- Languages
INSERT INTO languages(name,iso_639_1,iso_639_3,historical_name,description) VALUES
('Hebrew','he','heb','Hebreo bíblico','Hebreo de los testimonios bíblicos hebreos.'),
('Ancient Greek','el','grc','Griego antiguo','Griego de los testimonios antiguos.'),
('Coptic',NULL,'cop','Copto','Lengua del testimonio copto de Nag Hammadi.'),
('Spanish','es','spa','Español','Lengua de trabajo del corpus.')
;

-- Scripts
INSERT INTO scripts(name,iso_15924,description) VALUES
('Hebrew script','Hebr','Escritura hebrea cuadrada/paleográfica.'),
('Greek script','Grek','Escritura griega.'),
('Coptic script','Copt','Escritura copta.'),
('Latin script','Latn','Escritura latina.')
;

-- Sources: stable bibliographic anchors used by the fixtures.
INSERT INTO sources(id,source_type,title,author_text,publisher,publication_year,doi,url,notes) VALUES
(entity_id('source','day-2013-genesis-flood'),
 'academic_chapter','Comparative Ancient Near Eastern Study: The Genesis Flood Narrative in Relation to Ancient Near Eastern Flood Accounts',
 'John Day','Oxford University Press',2013,'10.1093/acprof:oso/9780199645534.003.0007',
 'https://academic.oup.com/book/35373/chapter/301258660',
 'Comparison of Genesis 6–8 with Sumerian, Atrahasis, Gilgamesh and Berossus traditions; explicitly evaluates possible direct and indirect dependence.'),
(entity_id('source','chen-2013-flood'),
 'academic_monograph','The Primeval Flood Catastrophe: Origins and Early Development in Mesopotamian Traditions',
 'Y. S. Chen','Oxford University Press',2013,'10.1093/acprof:oso/9780199676200.001.0001',
 'https://academic.oup.com/book/8443',
 'Study of the development of Mesopotamian flood traditions across a long textual history.'),
(entity_id('source','genesis-dss-overview'),
 'academic_reference','Genesis 1-11: A New Translation with Introduction and Commentary',
 'Source record for the Dead Sea Scrolls discussion','JSTOR',NULL,NULL,
 'https://www.jstor.org/stable/jj.18137929',
 'Reports fragmentary Genesis manuscripts from the Dead Sea Scrolls and their chronological range.'),
(entity_id('source','rahlfs-hanhart-2006'),
 'critical_edition','Septuaginta: Id est Vetus Testamentum graece iuxta LXX interpretes. Editio altera',
 'Alfred Rahlfs; Robert Hanhart','Deutsche Bibelgesellschaft',2006,NULL,
 'https://www.die-bibel.de/de/bible-society-and-biblical-studies/scholarly-editions/septuagint/septuaginta-deutsch/wissenschaftliche-ausgaben/septuaginta',
 'Critical Greek edition; revised edition published in 2006.'),
(entity_id('source','matthew-24-3-greek-witnesses'),
 'textual_reference','Matthew 24:3 — Greek textual witnesses',
 'Compiled witness-level reference',NULL,NULL,NULL,
 'https://biblehub.com/texts/matthew/24-3.htm',
 'Reference lists readings attributed to Codex Sinaiticus, Vaticanus, Ephraemi and other witnesses. Use as a fixture locator, not as the sole critical edition.'),
(entity_id('source','brill-coptic-gnostic-library'),
 'scholarly_edition','Coptic Gnostic Library Online',
 'Brill','Brill',NULL,NULL,
 'https://scholarlyeditions.brill.com/cglo/',
 'Scholarly edition platform containing Nag Hammadi texts including NHC II,2, Gospel of Thomas.'),
(entity_id('source','nasscal-thomas'),
 'scholarly_reference','Gospel of Thomas — e-Clavis Christian Apocrypha',
 'NASSCAL',NULL,NULL,NULL,
 'https://www.nasscal.com/e-clavis-christian-apocrypha/gospel-of-thomas/',
 'Summarizes the Coptic witness and three Greek Oxyrhynchus fragments.'),
(entity_id('source','berger-et-al-2025-naledi'),
 'peer_reviewed_article','Evidence for deliberate burial of the dead by Homo naledi',
 'Lee R. Berger et al.','eLife',2025,'10.7554/eLife.89106.3',
 'https://elifesciences.org/articles/89106v1',
 'Version of Record dated 2025-09-01. Presents evidence and a minimal hypothesis of cultural burial; peer review notes disagreement about whether the conclusion is unambiguous.'),
(entity_id('source','berger-et-al-meaning-2025'),
 'peer_reviewed_article','Meaning-making behavior in a small-brained hominin, Homo naledi, from the late Pleistocene: contexts and evolutionary implications',
 'Lee R. Berger et al.','eLife',2025,'10.7554/eLife.89125.3',
 'https://elifesciences.org/articles/89125',
 'Discusses mortuary behavior and meaning-making as interpretive categories, without requiring a religious-belief claim.')
;

-- Traditions and works
INSERT INTO traditions(id,name,description,tradition_type) VALUES
(entity_id('tradition','ancient-israelite-jewish-textual'),
 'Tradiciones textuales israelitas/judías antiguas',
 'Agrupa contextos de transmisión de textos bíblicos hebreos y griegos sin asumir una única forma textual original.',
 'textual'),
(entity_id('tradition','early-christian-gospel'),
 'Tradiciones cristianas antiguas de evangelios y dichos',
 'Contexto amplio para testimonios griegos y coptos de textos cristianos antiguos.',
 'textual'),
(entity_id('tradition','mesopotamian-flood'),
 'Tradiciones mesopotámicas del diluvio',
 'Conjunto de tradiciones literarias mesopotámicas sobre el motivo del diluvio.',
 'comparative'),
(entity_id('tradition','archaeological-mortuary'),
 'Arqueología del comportamiento mortuorio',
 'Categoría comparativa para evidencia material de tratamiento de los muertos.',
 'archaeological')
;

INSERT INTO works(id,title,description,status) VALUES
(entity_id('work','genesis'),
 'Genesis',
 'Obra bíblica transmitida en múltiples testigos hebreos y griegos.',
 'cataloged'),
(entity_id('work','gospel-of-matthew'),
 'Gospel of Matthew',
 'Obra cristiana antigua conservada en numerosos testimonios manuscritos y versiones.',
 'cataloged'),
(entity_id('work','gospel-of-thomas'),
 'Gospel of Thomas',
 'Colección de 114 dichos conservada íntegramente en copto en NHC II,2 y parcialmente en tres fragmentos griegos de Oxyrhynchus.',
 'cataloged'),
(entity_id('work','atrahasis'),
 'Atrahasis',
 'Tradición literaria mesopotámica que incluye un relato del diluvio.',
 'cataloged'),
(entity_id('work','gilgamesh'),
 'Epic of Gilgamesh',
 'Tradición literaria mesopotámica con el episodio del diluvio en la versión estándar.',
 'cataloged'),
(entity_id('work','babyloniaca'),
 'Babyloniaca of Berossus',
 'Obra historiográfica helenística conservada principalmente por citas posteriores; incluida aquí sólo como tradición comparativa.',
 'cataloged')
;

INSERT INTO work_traditions(work_id,tradition_id,relationship_type,confidence_id,source_id) VALUES
(entity_id('work','genesis'),entity_id('tradition','ancient-israelite-jewish-textual'),'context',entity_id('confidence_level','dummy'),entity_id('source','genesis-dss-overview')),
(entity_id('work','gospel-of-matthew'),entity_id('tradition','early-christian-gospel'),'context',entity_id('confidence_level','dummy'),entity_id('source','matthew-24-3-greek-witnesses')),
(entity_id('work','gospel-of-thomas'),entity_id('tradition','early-christian-gospel'),'context',entity_id('confidence_level','dummy'),entity_id('source','nasscal-thomas')),
(entity_id('work','atrahasis'),entity_id('tradition','mesopotamian-flood'),'context',entity_id('confidence_level','dummy'),entity_id('source','chen-2013-flood')),
(entity_id('work','gilgamesh'),entity_id('tradition','mesopotamian-flood'),'context',entity_id('confidence_level','dummy'),entity_id('source','day-2013-genesis-flood')),
(entity_id('work','babyloniaca'),entity_id('tradition','mesopotamian-flood'),'context',entity_id('confidence_level','dummy'),entity_id('source','day-2013-genesis-flood'))
;

COMMIT;

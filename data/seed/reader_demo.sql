-- Reader-layer demonstration seed.
-- Uses only a short, explicitly identified textual sample.
BEGIN;

CREATE FUNCTION pg_temp.entity_id(p_type text, p_key text)
RETURNS uuid
LANGUAGE plpgsql
AS $reader$
DECLARE v_id uuid;
BEGIN
  SELECT id INTO v_id FROM entities WHERE entity_type = p_type AND stable_key = p_key;
  IF v_id IS NULL THEN RAISE EXCEPTION 'Reader demo entity not found: % / %', p_type, p_key; END IF;
  RETURN v_id;
END $reader$;

INSERT INTO entities(entity_type, stable_key) VALUES
    ('unit_content','matthew-24-3-regius-original'),
    ('unit_content','matthew-24-3-regius-transliteration')
ON CONFLICT (entity_type, stable_key) DO NOTHING;

INSERT INTO textual_unit_contents(id,textual_unit_id,representation_type,text_content,normalized_text,source_id,notes) VALUES
(pg_temp.entity_id('unit_content','matthew-24-3-regius-original'),pg_temp.entity_id('unit','matthew-24-3-regius'),'original','Εἰπον ἡμῖν','ειπον ημιν',pg_temp.entity_id('source','csntm-ga019'),'Short witness-level sample used by the textual-variant reader; it is not presented as the complete verse.'),
(pg_temp.entity_id('unit_content','matthew-24-3-regius-transliteration'),pg_temp.entity_id('unit','matthew-24-3-regius'),'transliteration','Eipon hēmin',NULL,pg_temp.entity_id('source','csntm-ga019'),'Transliteration of the short witness-level sample.');

INSERT INTO entities(entity_type,stable_key) VALUES
    ('source','biblioteca-matthew-working-translation'),
    ('source','westcott-hort-1881'),
    ('edition','westcott-hort-1881'),
    ('translation','matthew-working-spanish')
ON CONFLICT (entity_type,stable_key) DO NOTHING;

INSERT INTO sources(id,source_type,title,author_text,publisher,publication_year,url,notes) VALUES
(pg_temp.entity_id('source','westcott-hort-1881'),
 'critical_edition',
 'The New Testament in the Original Greek',
 'Brooke Foss Westcott; Fenton John Anthony Hort',
 'Harper & Brothers',1881,
 'https://www.loc.gov/item/26007331/',
 'Edición crítica histórica de 1881. La Biblioteca del Congreso identifica esta edición como obra en dominio público.')
ON CONFLICT DO NOTHING;

INSERT INTO editions(id,title,publisher,publication_year,edition_type,source_id)
VALUES(
  pg_temp.entity_id('edition','westcott-hort-1881'),
  'The New Testament in the Original Greek',
  'Harper & Brothers',1881,'critical_edition',
  pg_temp.entity_id('source','westcott-hort-1881')
)
ON CONFLICT DO NOTHING;

INSERT INTO sources(id,source_type,title,author_text,publisher,publication_year,doi,url,notes) VALUES
(pg_temp.entity_id('source','biblioteca-matthew-working-translation'),'editorial_translation','Biblioteca de lo Sagrado — traducción de trabajo de Mateo 24:3–5','Biblioteca de lo Sagrado',NULL,NULL,NULL,NULL,'Traducción propia para el piloto del lector. Debe distinguirse de traducciones editoriales publicadas.')
ON CONFLICT DO NOTHING;

INSERT INTO translations(id,title,target_language_id,translator_notes,description) VALUES
(pg_temp.entity_id('translation','matthew-working-spanish'),'Mateo 24:3–5 — traducción de trabajo del corpus',(SELECT id FROM languages WHERE iso_639_3='spa'),'Traducción propia, orientada a fidelidad semántica y transparencia léxica; no pretende reproducir una traducción comercial.','Primera unidad continua del corpus de lectura. Se conserva separada de los testigos griegos.')
ON CONFLICT DO NOTHING;

INSERT INTO translation_sources(translation_id,edition_id,witness_id,source_type,notes) VALUES
(pg_temp.entity_id('translation','matthew-working-spanish'),pg_temp.entity_id('edition','westcott-hort-1881'),NULL,'edition','Edición griega histórica utilizada como referencia textual para esta traducción de trabajo.'),
(pg_temp.entity_id('translation','matthew-working-spanish'),NULL,pg_temp.entity_id('witness','matthew-regius-24-3'),'witness','GA 019 se conserva como referencia manuscrita para Mateo 24:3; 24:4–5 no se presentan como lecturas específicas de GA 019.')
ON CONFLICT DO NOTHING;

INSERT INTO entities(entity_type,stable_key) VALUES
('unit','matthew-24-3-working-spanish'),('unit','matthew-24-4-working-spanish'),('unit','matthew-24-5-working-spanish'),
('unit','matthew-24-3-westcott-hort'),('unit','matthew-24-4-westcott-hort'),('unit','matthew-24-5-westcott-hort'),
('unit_content','matthew-24-3-working-spanish-close'),('unit_content','matthew-24-3-working-spanish-readable'),
('unit_content','matthew-24-4-working-spanish-close'),('unit_content','matthew-24-4-working-spanish-readable'),
('unit_content','matthew-24-5-working-spanish-close'),('unit_content','matthew-24-5-working-spanish-readable')
ON CONFLICT (entity_type,stable_key) DO NOTHING;

INSERT INTO textual_units(id,parent_id,witness_id,translation_id,edition_id,unit_type,label,ordinal,path_key) VALUES
(pg_temp.entity_id('unit','matthew-24-3-working-spanish'),NULL,NULL,pg_temp.entity_id('translation','matthew-working-spanish'),NULL,'verse','Mateo 24:3',3,'matthew.24.3'),
(pg_temp.entity_id('unit','matthew-24-4-working-spanish'),NULL,NULL,pg_temp.entity_id('translation','matthew-working-spanish'),NULL,'verse','Mateo 24:4',4,'matthew.24.4'),
(pg_temp.entity_id('unit','matthew-24-5-working-spanish'),NULL,NULL,pg_temp.entity_id('translation','matthew-working-spanish'),NULL,'verse','Mateo 24:5',5,'matthew.24.5'),
(pg_temp.entity_id('unit','matthew-24-3-westcott-hort'),NULL,NULL,NULL,pg_temp.entity_id('edition','westcott-hort-1881'),'verse','Mateo 24:3',3,'matthew.24.3'),
(pg_temp.entity_id('unit','matthew-24-4-westcott-hort'),NULL,NULL,NULL,pg_temp.entity_id('edition','westcott-hort-1881'),'verse','Mateo 24:4',4,'matthew.24.4'),
(pg_temp.entity_id('unit','matthew-24-5-westcott-hort'),NULL,NULL,NULL,pg_temp.entity_id('edition','westcott-hort-1881'),'verse','Mateo 24:5',5,'matthew.24.5')
ON CONFLICT DO NOTHING;

INSERT INTO entities(entity_type,stable_key) VALUES
('unit_content','matthew-24-3-critical-text'),
('unit_content','matthew-24-3-transliteration'),
('unit_content','matthew-24-4-critical-text'),
('unit_content','matthew-24-4-transliteration'),
('unit_content','matthew-24-5-critical-text'),
('unit_content','matthew-24-5-transliteration')
ON CONFLICT (entity_type,stable_key) DO NOTHING;

INSERT INTO textual_unit_contents(id,textual_unit_id,representation_type,text_content,normalized_text,source_id,notes) VALUES
(pg_temp.entity_id('unit_content','matthew-24-3-critical-text'),pg_temp.entity_id('unit','matthew-24-3-westcott-hort'),'critical_text','Καθημένου δὲ αὐτοῦ ἐπὶ τοῦ Ὄρους τῶν Ἐλαιῶν προσῆλθον αὐτῷ οἱ μαθηταὶ κατ’ ἰδίαν λέγοντες· Εἰπὸν ἡμῖν πότε ταῦτα ἔσται, καὶ τί τὸ σημεῖον τῆς σῆς παρουσίας καὶ συντελείας τοῦ αἰῶνος.',NULL,pg_temp.entity_id('source','westcott-hort-1881'),'Westcott-Hort 1881. Se conserva como edición crítica histórica, no como una lectura manuscrita individual.'),
(pg_temp.entity_id('unit_content','matthew-24-3-transliteration'),pg_temp.entity_id('unit','matthew-24-3-westcott-hort'),'transliteration','Kathēmenou de autou epi tou Orous tōn Elaiōn prosēlthon autō hoi mathētai kat’ idian legontes: Eipon hēmin pote tauta estai, kai ti to sēmeion tēs sēs parousias kai synteleias tou aiōnos.',NULL,pg_temp.entity_id('source','westcott-hort-1881'),'Transliteración de trabajo del texto crítico registrado.'),
(pg_temp.entity_id('unit_content','matthew-24-4-critical-text'),pg_temp.entity_id('unit','matthew-24-4-westcott-hort'),'critical_text','καὶ ἀποκριθεὶς ὁ Ἰησοῦς εἶπεν αὐτοῖς· Βλέπετε μή τις ὑμᾶς πλανήσῃ.',NULL,pg_temp.entity_id('source','westcott-hort-1881'),'Westcott-Hort 1881.'),
(pg_temp.entity_id('unit_content','matthew-24-4-transliteration'),pg_temp.entity_id('unit','matthew-24-4-westcott-hort'),'transliteration','Kai apokritheis ho Iēsous eipen autois: Blepete mē tis hymas planēsē.',NULL,pg_temp.entity_id('source','westcott-hort-1881'),'Transliteración de trabajo del texto crítico registrado.'),
(pg_temp.entity_id('unit_content','matthew-24-5-critical-text'),pg_temp.entity_id('unit','matthew-24-5-westcott-hort'),'critical_text','πολλοὶ γὰρ ἐλεύσονται ἐπὶ τῷ ὀνόματί μου λέγοντες· Ἐγώ εἰμι ὁ χριστός, καὶ πολλοὺς πλανήσουσιν.',NULL,pg_temp.entity_id('source','westcott-hort-1881'),'Westcott-Hort 1881.'),
(pg_temp.entity_id('unit_content','matthew-24-5-transliteration'),pg_temp.entity_id('unit','matthew-24-5-westcott-hort'),'transliteration','Polloi gar eleusontai epi tō onomati mou legontes: Egō eimi ho christos, kai pollous planēsousin.',NULL,pg_temp.entity_id('source','westcott-hort-1881'),'Transliteración de trabajo del texto crítico registrado.');

INSERT INTO textual_unit_contents(id,textual_unit_id,representation_type,text_content,normalized_text,source_id,notes) VALUES
(pg_temp.entity_id('unit_content','matthew-24-3-working-spanish-close'),pg_temp.entity_id('unit','matthew-24-3-working-spanish'),'close_translation','Mientras estaba sentado en el monte de los Olivos, se le acercaron los discípulos en privado, diciendo: «Dinos cuándo serán estas cosas, y cuál es la señal de tu presencia y de la consumación de la era».',NULL,pg_temp.entity_id('source','biblioteca-matthew-working-translation'),'Traducción propia. «αἰών» se representa aquí como «era»; no se equipara automáticamente con «mundo».'),
(pg_temp.entity_id('unit_content','matthew-24-3-working-spanish-readable'),pg_temp.entity_id('unit','matthew-24-3-working-spanish'),'readable_translation','Mientras Jesús estaba sentado en el monte de los Olivos, los discípulos se acercaron a él en privado y le preguntaron: «Dinos cuándo sucederán estas cosas y cuál será la señal de tu presencia y de la consumación de la era».',NULL,pg_temp.entity_id('source','biblioteca-matthew-working-translation'),'Versión legible propia del mismo pasaje.'),
(pg_temp.entity_id('unit_content','matthew-24-4-working-spanish-close'),pg_temp.entity_id('unit','matthew-24-4-working-spanish'),'close_translation','Y Jesús, respondiendo, les dijo: «Mirad que nadie os engañe».',NULL,pg_temp.entity_id('source','biblioteca-matthew-working-translation'),'Traducción propia.'),
(pg_temp.entity_id('unit_content','matthew-24-4-working-spanish-readable'),pg_temp.entity_id('unit','matthew-24-4-working-spanish'),'readable_translation','Jesús les respondió: «Tengan cuidado de que nadie los engañe».',NULL,pg_temp.entity_id('source','biblioteca-matthew-working-translation'),'Versión legible propia.'),
(pg_temp.entity_id('unit_content','matthew-24-5-working-spanish-close'),pg_temp.entity_id('unit','matthew-24-5-working-spanish'),'close_translation','Porque muchos vendrán en mi nombre, diciendo: «Yo soy el Cristo», y engañarán a muchos.',NULL,pg_temp.entity_id('source','biblioteca-matthew-working-translation'),'Traducción propia.'),
(pg_temp.entity_id('unit_content','matthew-24-5-working-spanish-readable'),pg_temp.entity_id('unit','matthew-24-5-working-spanish'),'readable_translation','Porque muchos vendrán usando mi nombre y dirán: «Yo soy el Cristo», y engañarán a muchos.',NULL,pg_temp.entity_id('source','biblioteca-matthew-working-translation'),'Versión legible propia.');

COMMIT;

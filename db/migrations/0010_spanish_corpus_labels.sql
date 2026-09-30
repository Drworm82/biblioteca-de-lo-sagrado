-- Current editorial corpus labels are Spanish. Original bibliographic titles remain unchanged.
BEGIN;
UPDATE works SET title='Génesis' WHERE id=(SELECT id FROM entities WHERE entity_type='work' AND stable_key='genesis');
UPDATE works SET title='Evangelio según Mateo' WHERE id=(SELECT id FROM entities WHERE entity_type='work' AND stable_key='gospel-of-matthew');
UPDATE works SET title='Evangelio de Tomás' WHERE id=(SELECT id FROM entities WHERE entity_type='work' AND stable_key='gospel-of-thomas');
UPDATE works SET title='Atrahasis' WHERE id=(SELECT id FROM entities WHERE entity_type='work' AND stable_key='atrahasis');
UPDATE works SET title='Epopeya de Gilgamesh' WHERE id=(SELECT id FROM entities WHERE entity_type='work' AND stable_key='gilgamesh');
UPDATE works SET title='Babyloniaca de Beroso' WHERE id=(SELECT id FROM entities WHERE entity_type='work' AND stable_key='babyloniaca');
UPDATE textual_units SET label='Génesis 1:1–9' WHERE label='Genesis 1:1–9';
UPDATE textual_units SET label='Mateo 24:3' WHERE label='Matthew 24:3';
COMMIT;
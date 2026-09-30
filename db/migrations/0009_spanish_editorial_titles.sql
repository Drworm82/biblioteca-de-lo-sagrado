-- Spanish editorial title for the current application language.
-- Bibliographic source titles remain in their original publication language.
BEGIN;

UPDATE works
SET title='Evangelio según Mateo'
WHERE id=(SELECT id FROM entities WHERE entity_type='work' AND stable_key='gospel-of-matthew');

COMMIT;

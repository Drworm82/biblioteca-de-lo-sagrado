-- Timeline schema validation
DO $$
DECLARE
    event_id uuid;
BEGIN
    INSERT INTO entities(entity_type, stable_key)
    VALUES ('historical_event','test-historical-event')
    RETURNING id INTO event_id;

    INSERT INTO historical_events(id,title,event_type,description)
    VALUES (
        event_id,
        'Test historical event',
        'test',
        'Synthetic fixture used to validate the timeline event layer.'
    );

    IF NOT EXISTS (
        SELECT 1 FROM historical_events WHERE id=event_id
    ) THEN
        RAISE EXCEPTION 'Historical event fixture was not persisted';
    END IF;

    INSERT INTO dating_assertions(entity_id,earliest,latest,precision,dating_method)
    VALUES (event_id,-500,-400,'range','test');

    IF NOT EXISTS (
        SELECT 1 FROM dating_assertions
        WHERE entity_id=event_id AND earliest=-500 AND latest=-400
    ) THEN
        RAISE EXCEPTION 'Historical event dating assertion was not persisted';
    END IF;
END $$;

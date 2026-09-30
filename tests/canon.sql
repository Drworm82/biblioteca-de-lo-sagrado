-- Canon status schema validation
DO $$
DECLARE
    v_work_id uuid;
    v_tradition_id uuid;
    v_period_id uuid;
    v_status_id uuid;
BEGIN
    INSERT INTO entities(entity_type, stable_key) VALUES ('work','test-canon-work') RETURNING id INTO v_work_id;
    INSERT INTO works(id,title,status) VALUES (v_work_id,'Test canon work','test');
    INSERT INTO entities(entity_type, stable_key) VALUES ('tradition','test-canon-tradition') RETURNING id INTO v_tradition_id;
    INSERT INTO traditions(id,name) VALUES (v_tradition_id,'Test tradition');
    INSERT INTO entities(entity_type, stable_key) VALUES ('period','test-canon-period') RETURNING id INTO v_period_id;
    INSERT INTO periods(id,name,earliest,latest) VALUES (v_period_id,'Test period',100,200);
    INSERT INTO canon_statuses(work_id,tradition_id,community,period_id,status,notes)
    VALUES (v_work_id,v_tradition_id,'Test community',v_period_id,'disputed','Synthetic fixture.');
    SELECT id INTO v_status_id FROM canon_statuses WHERE canon_statuses.work_id=v_work_id AND community='Test community';
    IF v_status_id IS NULL THEN RAISE EXCEPTION 'Canon status fixture was not persisted'; END IF;
END $$;
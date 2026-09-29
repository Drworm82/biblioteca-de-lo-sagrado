-- Biblioteca de lo Sagrado
-- End-to-end PostgreSQL validation for the first textual reader layer.
BEGIN;

DO $$
DECLARE
  v_work uuid;
  v_regius_unit uuid;
  v_content_count integer;
  v_original text;
  v_transliteration text;
  v_original_source text;
  v_regius_reading_count integer;
  v_reader_row_count integer;
BEGIN
  SELECT e.id
    INTO v_work
  FROM entities e
  WHERE e.entity_type = 'work'
    AND e.stable_key = 'gospel-of-matthew';

  IF v_work IS NULL THEN
    RAISE EXCEPTION 'Reader validation: Gospel of Matthew work not found';
  END IF;

  SELECT tu.id
    INTO v_regius_unit
  FROM textual_units tu
  JOIN entities e ON e.id = tu.id
  WHERE e.stable_key = 'matthew-24-3-regius';

  IF v_regius_unit IS NULL THEN
    RAISE EXCEPTION 'Reader validation: GA 019 textual unit not found';
  END IF;

  SELECT count(*)
    INTO v_content_count
  FROM textual_unit_contents
  WHERE textual_unit_id = v_regius_unit;

  IF v_content_count <> 2 THEN
    RAISE EXCEPTION 'Reader validation: expected 2 content layers for GA 019, got %', v_content_count;
  END IF;

  SELECT text_content
    INTO v_original
  FROM textual_unit_contents
  WHERE textual_unit_id = v_regius_unit
    AND representation_type = 'original';

  IF v_original <> 'Εἰπον ἡμῖν' THEN
    RAISE EXCEPTION 'Reader validation: unexpected original reading: %', v_original;
  END IF;

  SELECT text_content
    INTO v_transliteration
  FROM textual_unit_contents
  WHERE textual_unit_id = v_regius_unit
    AND representation_type = 'transliteration';

  IF v_transliteration <> 'Eipon hēmin' THEN
    RAISE EXCEPTION 'Reader validation: unexpected transliteration: %', v_transliteration;
  END IF;

  SELECT s.title
    INTO v_original_source
  FROM textual_unit_contents tuc
  JOIN sources s ON s.id = tuc.source_id
  WHERE tuc.textual_unit_id = v_regius_unit
    AND tuc.representation_type = 'original';

  IF v_original_source <> 'Manuscript GA 019 — Codex Regius' THEN
    RAISE EXCEPTION 'Reader validation: original source is not CSNTM GA 019: %', v_original_source;
  END IF;

  SELECT count(*)
    INTO v_regius_reading_count
  FROM textual_variant_readings tvr
  WHERE tvr.witness_id = (
    SELECT tw.id
    FROM textual_witnesses tw
    JOIN entities e ON e.id = tw.id
    WHERE e.stable_key = 'matthew-regius-24-3'
  );

  IF v_regius_reading_count <> 1 THEN
    RAISE EXCEPTION 'Reader validation: expected 1 GA 019 variant reading, got %', v_regius_reading_count;
  END IF;

  -- Reproduce the essential reader join: the variant is anchored to one unit,
  -- while readings can come from corresponding units in other witnesses.
  SELECT count(*)
    INTO v_reader_row_count
  FROM textual_variant_readings tvr
  JOIN textual_variants tv ON tv.id = tvr.variant_id
  JOIN entities anchor_entity ON anchor_entity.id = tv.textual_unit_id
  JOIN textual_units reading_unit ON reading_unit.id = tvr.textual_unit_id
  JOIN textual_witnesses reading_witness ON reading_witness.id = tvr.witness_id
  JOIN works w ON w.id = reading_witness.work_id
  WHERE anchor_entity.stable_key = 'matthew-24-3-sinaiticus'
    AND w.id = v_work;

  IF v_reader_row_count <> 4 THEN
    RAISE EXCEPTION 'Reader validation: expected 4 readings under the imperative variant, got %', v_reader_row_count;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM textual_variant_readings tvr
    JOIN textual_units tu ON tu.id = tvr.textual_unit_id
    JOIN entities unit_entity ON unit_entity.id = tu.id
    JOIN textual_witnesses tw ON tw.id = tvr.witness_id
    JOIN entities witness_entity ON witness_entity.id = tw.id
    WHERE unit_entity.stable_key = 'matthew-24-3-regius'
      AND witness_entity.stable_key = 'matthew-regius-24-3'
      AND tvr.reading_text = 'ειπον ημιν'
  ) THEN
    RAISE EXCEPTION 'Reader validation: GA 019 reading is not attached to the GA 019 unit/witness pair';
  END IF;

  -- The contiguous Spanish pilot must contain exactly three verse units.
  SELECT count(*)
    INTO v_reader_row_count
  FROM textual_units tu
  JOIN entities e ON e.id = tu.id
  JOIN translations tr ON tr.id = tu.translation_id
  JOIN entities te ON te.id = tr.id
  WHERE te.stable_key = 'matthew-working-spanish'
    AND e.stable_key IN (
      'matthew-24-3-working-spanish',
      'matthew-24-4-working-spanish',
      'matthew-24-5-working-spanish'
    );

  IF v_reader_row_count <> 3 THEN
    RAISE EXCEPTION 'Reader validation: expected 3 contiguous Matthew translation units, got %', v_reader_row_count;
  END IF;

  SELECT count(*)
    INTO v_reader_row_count
  FROM textual_unit_contents tuc
  JOIN textual_units tu ON tu.id = tuc.textual_unit_id
  JOIN entities e ON e.id = tu.id
  WHERE e.stable_key IN (
      'matthew-24-3-working-spanish',
      'matthew-24-4-working-spanish',
      'matthew-24-5-working-spanish'
    )
    AND tuc.representation_type IN ('close_translation','readable_translation');

  IF v_reader_row_count <> 6 THEN
    RAISE EXCEPTION 'Reader validation: expected 6 Spanish pilot content layers, got %', v_reader_row_count;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM textual_unit_contents tuc
    JOIN textual_units tu ON tu.id=tuc.textual_unit_id
    JOIN entities e ON e.id=tu.id
    WHERE e.stable_key='matthew-24-4-working-spanish'
      AND tuc.representation_type='readable_translation'
      AND tuc.text_content LIKE 'Jesús les respondió%'
  ) THEN
    RAISE EXCEPTION 'Reader validation: Matthew 24:4 readable translation missing';
  END IF;

END $;

ROLLBACK;

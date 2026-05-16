-- Script to remove the series data that was already inserted

-- Delete the series records that were inserted
DELETE FROM series WHERE code IN ('F30', 'G20', 'F15', 'G05');

-- Also remove any series_id references from cars table that were set
UPDATE cars SET series_id = NULL WHERE series_id IS NOT NULL;

-- Requirements #2 and #6 for the room_types table.
--   #2: capacity_adult + capacity_child  ->  capacity_guest
--   #6: new max_capacity_guest and extra_guest_price_per_night columns
--
-- There is no migration tool in this project, so run this by hand against each database.
--
-- NOTE ON ORDERING: the app runs with ddl-auto=update, so if you deploy the new build
-- FIRST, Hibernate will already have created all three new columns (empty) and the three
-- ADD COLUMN statements below will fail with "Duplicate column name" -- just skip them and
-- start from the UPDATEs. If you run this script first, keep everything as-is.

-- 1. New columns ------------------------------------------------------------
ALTER TABLE room_types ADD COLUMN capacity_guest INT NULL;
ALTER TABLE room_types ADD COLUMN max_capacity_guest INT NULL;
ALTER TABLE room_types ADD COLUMN extra_guest_price_per_night DOUBLE NULL;

-- 2. Backfill ---------------------------------------------------------------
-- Generic fallback for any room type not named below: adults + children.
UPDATE room_types
SET capacity_guest = COALESCE(capacity_adult, 0) + COALESCE(capacity_child, 0)
WHERE capacity_guest IS NULL;

-- Business-defined values.
UPDATE room_types SET capacity_guest = 2, max_capacity_guest = 3, extra_guest_price_per_night = 735 WHERE type_name = 'Non-AC Room';
UPDATE room_types SET capacity_guest = 2, max_capacity_guest = 3, extra_guest_price_per_night = 735 WHERE type_name = 'Deluxe Room';
UPDATE room_types SET capacity_guest = 3, max_capacity_guest = 4, extra_guest_price_per_night = 735 WHERE type_name = 'Executive Room';

-- Safety net so nothing is left null for room types not covered above.
UPDATE room_types
SET max_capacity_guest = capacity_guest + 1
WHERE max_capacity_guest IS NULL;

UPDATE room_types
SET extra_guest_price_per_night = 735
WHERE extra_guest_price_per_night IS NULL;

-- 3. Verify before dropping anything ----------------------------------------
-- SELECT id, type_name, capacity_adult, capacity_child,
--        capacity_guest, max_capacity_guest, extra_guest_price_per_night
-- FROM room_types;

-- 4. Drop the old columns ---------------------------------------------------
ALTER TABLE room_types DROP COLUMN capacity_adult;
ALTER TABLE room_types DROP COLUMN capacity_child;

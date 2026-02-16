-- ============================================================================
-- DATA1500 - Oblig 1: Arbeidskrav I våren 2026
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller
    DROP TABLE IF EXISTS rental CASCADE;
    DROP TABLE IF EXISTS bike CASCADE;
    DROP TABLE IF EXISTS customer CASCADE;
    DROP TABLE IF EXISTS bike_lock CASCADE;
    DROP TABLE IF EXISTS station CASCADE;


    -- -------------------
-- STATION
-- -------------------
CREATE TABLE station (
  station_id BIGSERIAL PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  location TEXT,
  CONSTRAINT station_name_not_empty CHECK (length(trim(name)) > 0)
);

-- -------------------
-- CUSTOMER
-- -------------------
CREATE TABLE customer (
  customer_id BIGSERIAL PRIMARY KEY,
  mobile_number VARCHAR(20) NOT NULL,
  email VARCHAR(320) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,

  CONSTRAINT customer_mobile_format CHECK (mobile_number ~ '^\+?[0-9]{8,20}$'),
  CONSTRAINT customer_email_format CHECK (email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'),
  CONSTRAINT customer_first_name_not_empty CHECK (length(trim(first_name)) > 0),
  CONSTRAINT customer_last_name_not_empty CHECK (length(trim(last_name)) > 0)
);

CREATE UNIQUE INDEX customer_email_uq ON customer (email);
CREATE UNIQUE INDEX customer_mobile_uq ON customer (mobile_number);

-- -------------------
-- LOCK
-- -------------------
CREATE TABLE bike_lock (
  lock_id BIGSERIAL PRIMARY KEY,
  station_id BIGINT NOT NULL REFERENCES station(station_id)
);


-- -------------------
-- BIKE
-- -------------------
CREATE TABLE bike (
  bike_id BIGSERIAL PRIMARY KEY,
  station_id BIGINT NULL REFERENCES station(station_id),
  lock_id BIGINT NULL REFERENCES bike_lock(lock_id)

);

CREATE UNIQUE INDEX bike_lock_uq_not_null ON bike(lock_id) WHERE lock_id IS NOT NULL;

-- -------------------
-- RENTAL
-- -------------------
CREATE TABLE rental (
  rental_id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customer(customer_id),
  bike_id BIGINT NOT NULL REFERENCES bike(bike_id),
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NULL,
  amount NUMERIC(10,2) NOT NULL DEFAULT 0,

  CONSTRAINT rental_end_after_start CHECK (end_time IS NULL OR end_time >= start_time),
  CONSTRAINT rental_amount_nonnegative CHECK (amount >= 0)
);

CREATE UNIQUE INDEX rental_one_active_per_bike
ON rental (bike_id)
WHERE end_time IS NULL;





-- Sett inn testdata
-- -------------------

-- Stations
INSERT INTO station (name, location) VALUES
  ('Sentrum', 'Oslo sentrum'),
  ('Majorstuen', 'Majorstuen'),
  ('Nydalen', 'Nydalen');

-- Locks (each lock belongs to a station)
INSERT INTO bike_lock (station_id) VALUES
  (1), (1), (1),
  (2), (2),
  (3), (3);

-- Bikes (some parked with locks, some rented -> NULL station_id/lock_id)
INSERT INTO bike (station_id, lock_id) VALUES
  (1, 1),
  (1, 2),
  (2, 4),
  (3, 6),
  (NULL, NULL);  -- rented bike (currently out)

-- Customers
INSERT INTO customer (mobile_number, email, first_name, last_name) VALUES
  ('+4791111111', 'kunde1@example.com', 'Ali', 'Ahmadi'),
  ('+4792222222', 'kunde2@example.com', 'Sara', 'Hansen'),
  ('+4793333333', 'kunde3@example.com', 'Omar', 'Noori');

-- Rentals (one finished, one ongoing)
INSERT INTO rental (customer_id, bike_id, start_time, end_time, amount) VALUES
  (1, 1, '2026-02-10 10:00+01', '2026-02-10 10:30+01', 39.00),
  (2, 5, '2026-02-16 09:00+01', NULL, 0.00);



-- DBA setninger (rolle: kunde, bruker: kunde_1)



-- Eventuelt: Opprett indekser for ytelse



-- Vis at initialisering er fullført (kan se i loggen fra "docker-compose log"
SELECT 'Database initialisert!' as status;
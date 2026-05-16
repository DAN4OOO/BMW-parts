-- Migration script to add missing tables and columns for VIN-based diagram retrieval

-- 1. Create series table
CREATE TABLE series (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    code        VARCHAR(20)  NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    generation  VARCHAR(20)  NOT NULL,
    start_year  INT          NOT NULL,
    end_year    INT,
    description TEXT
);

-- 2. Add series_id column to cars table
ALTER TABLE cars

ADD COLUMN series_id BIGINT,
ADD CONSTRAINT fk_car_series FOREIGN KEY (series_id) REFERENCES series(id);

-- 3. Create vehicle_config table
CREATE TABLE vehicle_config (
    id          BIGINT       AUTO_INCREMENT PRIMARY KEY,
    model       VARCHAR(60)  NOT NULL,
    year_start  INT          NOT NULL,
    year_end    INT,
    engine      VARCHAR(60)  NOT NULL,
    generation  VARCHAR(20)  NOT NULL,
    description TEXT
);

-- 4. Remove description_bg column from component_groups table
ALTER TABLE component_groups DROP COLUMN description_bg;

-- 5. Add vehicle_config_id column to component_groups table
ALTER TABLE component_groups 
ADD COLUMN vehicle_config_id BIGINT,
ADD CONSTRAINT fk_cg_vehicle_config FOREIGN KEY (vehicle_config_id) REFERENCES vehicle_config(id);

-- 6. Add vehicle_config_id column to parts table
ALTER TABLE parts 
ADD COLUMN vehicle_config_id BIGINT,
ADD CONSTRAINT fk_p_vehicle_config FOREIGN KEY (vehicle_config_id) REFERENCES vehicle_config(id);

-- 7. Populate series table with BMW series data
INSERT INTO series (code, name, generation, start_year, end_year, description) VALUES
('F30', 'BMW 3 Series Sedan', 'F30', 2012, 2018, 'Sixth generation 3 Series sedan'),
('G20', 'BMW 3 Series Sedan', 'G20', 2019, 2025, 'Seventh generation 3 Series sedan'),
('F15', 'BMW X5', 'F15', 2014, 2018, 'Third generation X5 SUV'),
('G05', 'BMW X5', 'G05', 2019, 2023, 'Fourth generation X5 SUV');

-- 8. Update cars table with series_id based on series string
-- Disable safe mode temporarily
SET SQL_SAFE_UPDATES = 0;

UPDATE cars SET series_id = (SELECT id FROM series WHERE code = 'F30') WHERE series LIKE '%F30%';
UPDATE cars SET series_id = (SELECT id FROM series WHERE code = 'G20') WHERE series LIKE '%G20%';
UPDATE cars SET series_id = (SELECT id FROM series WHERE code = 'F15') WHERE series LIKE '%F15%';
UPDATE cars SET series_id = (SELECT id FROM series WHERE code = 'G05') WHERE series LIKE '%G05%';

-- Re-enable safe mode
SET SQL_SAFE_UPDATES = 1;

-- 9. Populate vehicle_config table with configurations
INSERT INTO vehicle_config (model, year_start, year_end, engine, generation, description) VALUES
('3 Series', 2018, 2018, 'B58B30', 'F30', 'F30 340i - 3.0L Inline-6 Turbo'),
('3 Series', 2021, 2021, 'B48B20', 'G20', 'G20 330i - 2.0L Inline-4 Turbo'),
('X5', 2019, 2019, 'B58B30', 'F15', 'F15 X5 xDrive40i - 3.0L Inline-6 Turbo');

-- 10. Update component_groups and parts with vehicle_config_id
-- Disable safe mode temporarily for these updates too
SET SQL_SAFE_UPDATES = 0;

-- For car 1 (F30 340i), vehicle_config_id = 1
UPDATE component_groups SET vehicle_config_id = 1 WHERE car_id = 1;
UPDATE parts SET vehicle_config_id = 1 WHERE car_id = 1;

-- For car 2 (G20 330i), vehicle_config_id = 2  
UPDATE component_groups SET vehicle_config_id = 2 WHERE car_id = 2;
UPDATE parts SET vehicle_config_id = 2 WHERE car_id = 2;

-- For car 3 (F15 X5), vehicle_config_id = 3
UPDATE component_groups SET vehicle_config_id = 3 WHERE car_id = 3;
UPDATE parts SET vehicle_config_id = 3 WHERE car_id = 3;

-- Re-enable safe mode
SET SQL_SAFE_UPDATES = 1;

DROP DATABASE IF EXISTS bmw_parts;
CREATE DATABASE bmw_parts CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bmw_parts;

CREATE TABLE cars (
                      id           BIGINT       AUTO_INCREMENT PRIMARY KEY,
                      vin          VARCHAR(17)  NOT NULL UNIQUE,
                      make         VARCHAR(60)  NOT NULL DEFAULT 'BMW',
                      model        VARCHAR(60)  NOT NULL,
                      series       VARCHAR(60),
                      year         INT          NOT NULL,
                      body         VARCHAR(60),
                      engine_code  VARCHAR(30),
                      engine_desc  VARCHAR(160),
                      fuel         VARCHAR(30),
                      gearbox      VARCHAR(80)
);

CREATE TABLE part_groups (
                             id         BIGINT       AUTO_INCREMENT PRIMARY KEY,
                             code       VARCHAR(60)  NOT NULL UNIQUE,
                             name_bg    VARCHAR(160) NOT NULL,
                             icon       VARCHAR(10)  NOT NULL DEFAULT '⚙️',
                             sort_order INT          NOT NULL DEFAULT 0
);

CREATE TABLE component_groups (
                                  id             BIGINT       AUTO_INCREMENT PRIMARY KEY,
                                  group_id       BIGINT       NOT NULL,
                                  car_id         BIGINT       NOT NULL,
                                  code           VARCHAR(100) NOT NULL,
                                  name_bg        VARCHAR(200) NOT NULL,
                                  diagram_path   VARCHAR(300),
                                  description_bg TEXT,
                                  sort_order     INT          NOT NULL DEFAULT 0,
                                  CONSTRAINT fk_cg_group FOREIGN KEY (group_id) REFERENCES part_groups(id),
                                  CONSTRAINT fk_cg_car FOREIGN KEY (car_id) REFERENCES cars(id),
                                  CONSTRAINT uk_component_group_car_code UNIQUE (car_id, code)
);

CREATE TABLE parts (
                       id                 BIGINT       AUTO_INCREMENT PRIMARY KEY,
                       component_group_id BIGINT       NOT NULL,
                       car_id             BIGINT       NOT NULL,
                       diagram_number     INT          NOT NULL,
                       name_bg            VARCHAR(255) NOT NULL,
                       oe_number          VARCHAR(60)  NOT NULL,
                       CONSTRAINT fk_p_cg FOREIGN KEY (component_group_id) REFERENCES component_groups(id),
                       CONSTRAINT fk_p_car FOREIGN KEY (car_id) REFERENCES cars(id)
);

CREATE TABLE part_prices (
                             id        BIGINT        AUTO_INCREMENT PRIMARY KEY,
                             part_id   BIGINT        NOT NULL,
                             brand     VARCHAR(100)  NOT NULL,
                             price_min DECIMAL(10,2) NOT NULL,
                             price_max DECIMAL(10,2) NOT NULL,
                             currency  VARCHAR(5)    NOT NULL DEFAULT 'лв.',
                             shop_url  VARCHAR(600)  NOT NULL,
                             shop_name VARCHAR(120)  NOT NULL,
                             CONSTRAINT fk_pp_part FOREIGN KEY (part_id) REFERENCES parts(id)
);

INSERT INTO cars (vin,make,model,series,year,body,engine_code,engine_desc,fuel,gearbox)
VALUES 
('WBA8B3C55JK385192','BMW','3 Series','F30 340i',2018,
        'Седан','B58B30','3.0L Inline-6 Turbo 326к.с.','Бензин','8-степ. автоматична ZF8HP'),
('WBAJ31010V1234567','BMW','3 Series','G20 330i',2021,
        'Седан','B48B20','2.0L Inline-4 Turbo 258к.с.','Бензин','8-степ. автоматична ZF8HP'),
('5UXCR6C55NG123456','BMW','X5','F15 X5 xDrive40i',2019,
        'SUV','B58B30','3.0L Inline-6 Turbo 340к.с.','Бензин','8-степ. автоматична ZF8HP');

INSERT INTO part_groups (code, name_bg, icon, sort_order) VALUES
                                                              ('engine',          'Двигател',                          '⚙️',   1),
                                                              ('engine-electric', 'Електрическа система на двигателя', '⚡',   2),
                                                              ('fuel-prep',       'Система за подготовка на горивото', '🔧',   3),
                                                              ('fuel-supply',     'Горивоснабдяване',                  '⛽',   4),
                                                              ('radiator',        'Радиатор / Охладителна система',    '❄️',   5),
                                                              ('exhaust',         'Изпускателна система',              '💨',   6),
                                                              ('clutch',          'Съединител',                        '🔘',   7),
                                                              ('transmission',    'Скоростна кутия',                   '🔄',   8),
                                                              ('front-axle',      'Предна ос',                         '🔩',   9),
                                                              ('steering',        'Кормилно управление',               '🎯',  10),
                                                              ('rear-axle',       'Задна ос',                          '🔩',  11),
                                                              ('brakes',          'Спирачна система',                  '🛑',  12),
                                                              ('bodywork',        'Каросерия',                         '🚗',  13),
                                                              ('vehicle-trim',    'Интериор и екстериор',              '🪑',  14);

-- Create indexes for performance
CREATE INDEX idx_component_groups_car_id ON component_groups(car_id);
CREATE INDEX idx_parts_car_id ON parts(car_id);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (1,1,'eng-block',          'Блок на двигателя',                       NULL, 1),
                                                                                             (1,1,'eng-crankshaft',     'Колянов вал и бутала',                    NULL, 2),
                                                                                             (1,1,'eng-timing-cover',   'Капак на разпределението и уплътнение',   NULL, 3),
                                                                                             (1,1,'eng-timing-chain',   'Верига на разпределението',               NULL, 4),
                                                                                             (1,1,'eng-cylinder-head',  'Глава на цилиндрите',                     NULL, 5),
                                                                                             (1,1,'eng-valvetrain',     'Клапанен механизъм / VANOS',              NULL, 6),
                                                                                             (1,1,'eng-oil-pan',        'Маслена вана',                            NULL, 7),
                                                                                             (1,1,'eng-oil-pump',       'Маслена помпа',                           NULL, 8),
                                                                                             (1,1,'eng-oil-filter',     'Маслен филтър и корпус',                  NULL, 9),
                                                                                             (1,1,'eng-intake',         'Всмукателен колектор',                    NULL,10),
                                                                                             (1,1,'eng-turbo',          'Турбокомпресор',                          NULL,11),
                                                                                             (1,1,'eng-mounts',         'Тампони на двигателя',                    NULL,12),
                                                                                             (1,1,'eng-vacuum',         'Вакуумна система',                        NULL,13),
                                                                                             (1,1,'eng-belt-drive',     'Пистов ремък и обтегачи',                NULL,14);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (2,1,'elec-alternator',    'Генератор',                                      'алтернатор.jpg', 1),
                                                                                             (2,1,'elec-starter',       'Стартер',                                        'Стартер.jpg', 2),
                                                                                             (2,1,'elec-ignition',      'Бобини и свещи за запалване',                   'Бобини и свещи за запалване.jpg', 3),
                                                                                             (2,1,'elec-crank-sensor',  'Сензор за положение на коляновия вал',           'Сензор за положение на коляновия вал.jpg', 4),
                                                                                             (2,1,'elec-ecu',           'Управляващ блок на двигателя (DME)',             'Управляващ блок на двигателя (DME).jpg', 5),
                                                                                             (2,1,'elec-wiring',        'Кабелен сноп на двигателя',                     'Кабелен сноп на двигателя.jpg', 6);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (3,1,'fuel-injectors',     'Горивни инжектори',                             'Горивни инжектори.jpg', 1),
                                                                                             (3,1,'fuel-hp-pump',       'Горивна помпа с високо налягане',               'Горивна помпа с високо налягане.jpg', 2),
                                                                                             (3,1,'fuel-throttle',      'Дросел клапа',                                  'Дросел клапа.jpg', 3),
                                                                                             (3,1,'fuel-air-filter',    'Въздушен филтър и кутия',                      'Въздушен филтър и кутия.jpg', 4);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (4,1,'supply-tank',        'Горивен резервоар',                             NULL,NULL, 1),
                                                                                             (4,1,'supply-lp-pump',     'Горивна помпа ниско налягане (в резервоара)',   NULL,NULL, 2),
                                                                                             (4,1,'supply-fuel-filter', 'Горивен филтър',                                NULL,NULL, 3),
                                                                                             (4,1,'supply-filler',      'Гърловина за зареждане с гориво',              NULL,NULL, 4),
                                                                                             (4,1,'supply-lines',       'Горивопроводи',                                 NULL,NULL, 5),
                                                                                             (4,1,'supply-evap',        'EVAP система (абсорбатор с активен въглен)',    NULL,NULL, 6);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (5,1,'rad-radiator',       'Радиатор',                                      NULL,NULL, 1),
                                                                                             (5,1,'rad-water-pump',     'Водна помпа и термостат',                       NULL,NULL, 2),
                                                                                             (5,1,'rad-fan',            'Електрически вентилатор на радиатора',          NULL,NULL, 3),
                                                                                             (5,1,'rad-expansion',      'Разширителен съд',                              NULL,NULL, 4),
                                                                                             (5,1,'rad-hoses',          'Охладителни маркучи',                           NULL,NULL, 5),
                                                                                             (5,1,'rad-oil-cooler',     'Маслен охладител',                              NULL,NULL, 6),
                                                                                             (5,1,'rad-ac-condenser',   'Кондензатор на климатика',                      NULL,NULL, 7);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (6,1,'exh-manifold',       'Изпускателен колектор',                         NULL,NULL, 1),
                                                                                             (6,1,'exh-catalytic',      'Катализатор',                                   NULL,NULL, 2),
                                                                                             (6,1,'exh-dpf',            'Сажден / Бензинов частичен филтър (OPF)',       NULL,NULL, 3),
                                                                                             (6,1,'exh-mid-pipe',       'Средна тръба',                                  NULL,NULL, 4),
                                                                                             (6,1,'exh-muffler',        'Заден заглушител',                              NULL,NULL, 5),
                                                                                             (6,1,'exh-hangers',        'Окачване на изпускателната система',            NULL,NULL, 6);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (7,1,'clutch-assembly',    'Комплект съединител (диск и притискателна плоча)',NULL, 1),
                                                                                             (7,1,'clutch-flywheel',    'Двумасов маховик',                              NULL,NULL, 2),
                                                                                             (7,1,'clutch-bearing',     'Лагер на съединителя',                          NULL,NULL, 3),
                                                                                             (7,1,'clutch-master-cyl',  'Главен цилиндър на съединителя',                NULL,NULL, 4),
                                                                                             (7,1,'clutch-slave-cyl',   'Работен цилиндър на съединителя',               NULL,NULL, 5),
                                                                                             (7,1,'clutch-pedal',       'Педал на съединителя',                          NULL,NULL, 6);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (8,1,'gearbox-case',       'Корпус на скоростната кутия ZF8HP',             NULL,NULL, 1),
                                                                                             (8,1,'gearbox-torque-conv','Хидравличен съединител (Торкконвертор)',         NULL,NULL, 2),
                                                                                             (8,1,'gearbox-oil-pan',    'Маслена вана на скоростната кутия',             NULL,NULL, 3),
                                                                                             (8,1,'gearbox-valve-body', 'Хидравличен разпределителен блок',              NULL,NULL, 4),
                                                                                             (8,1,'gearbox-mounts',     'Тампони на скоростната кутия',                  NULL,NULL, 5),
                                                                                             (8,1,'gearbox-propshaft',  'Карданен вал',                                  NULL,NULL, 6),
                                                                                             (8,1,'gearbox-halfshaft',  'Полуоси',                                       NULL,NULL, 7),
                                                                                             (8,1,'gearbox-selector',   'Лост за избор на предавка (Shift by Wire)',     NULL,NULL, 8);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (9,1,'front-strut',        'Преден амортисьор / Макферсон стрът',           NULL,NULL, 1),
                                                                                             (9,1,'front-spring',       'Предна пружина',                                NULL,NULL, 2),
                                                                                             (9,1,'front-lower-arm',    'Долен носач предна ос',                         NULL,NULL, 3),
                                                                                             (9,1,'front-upper-arm',    'Горен носач предна ос',                         NULL,NULL, 4),
                                                                                             (9,1,'front-subframe',     'Предна напречна греда (Субрейм)',               NULL,NULL, 5),
                                                                                             (9,1,'front-hub',          'Главина и лагер предна ос',                     NULL,NULL, 6),
                                                                                             (9,1,'front-swaybar',      'Стабилизаторна щанга предна ос',               NULL,NULL, 7),
                                                                                             (9,1,'front-swaybar-link', 'Свързваща щанга на стабилизатора (предна)',    NULL,NULL, 8);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (10,1,'steer-rack',        'Кормилна рейка (електрическа)',                 NULL,NULL, 1),
                                                                                             (10,1,'steer-column',      'Кормилна колона',                               NULL,NULL, 2),
                                                                                             (10,1,'steer-wheel',       'Волан',                                         NULL,NULL, 3),
                                                                                             (10,1,'steer-tie-rod',     'Напречна щанга и кормилен накрайник',          NULL,NULL, 4);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (11,1,'rear-shock',        'Заден амортисьор',                              NULL,NULL, 1),
                                                                                             (11,1,'rear-spring',       'Задна пружина',                                 NULL,NULL, 2),
                                                                                             (11,1,'rear-upper-arm',    'Горен напречен носач задна ос',                NULL,NULL, 3),
                                                                                             (11,1,'rear-lower-arm',    'Долен напречен носач задна ос',                NULL,NULL, 4),
                                                                                             (11,1,'rear-trailing-arm', 'Надлъжен носач задна ос',                      NULL,NULL, 5),
                                                                                             (11,1,'rear-subframe',     'Задна напречна греда (Субрейм)',               NULL,NULL, 6),
                                                                                             (11,1,'rear-hub',          'Главина и лагер задна ос',                     NULL,NULL, 7),
                                                                                             (11,1,'rear-swaybar',      'Стабилизаторна щанга задна ос',               NULL,NULL, 8),
                                                                                             (11,1,'rear-swaybar-link', 'Свързваща щанга на стабилизатора (задна)',    NULL,NULL, 9),
                                                                                             (11,1,'rear-diff',         'Заден диференциал',                             NULL,NULL,10);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (12,1,'brake-front',       'Предни спирачки — диск, апарат, накладки',    NULL,NULL, 1),
                                                                                             (12,1,'brake-rear',        'Задни спирачки — диск, апарат, накладки',     NULL,NULL, 2),
                                                                                             (12,1,'brake-master-cyl',  'Главен спирачен цилиндър',                    NULL,NULL, 3),
                                                                                             (12,1,'brake-servo',       'Вакуумен усилвател на спирачките',             NULL,NULL, 4),
                                                                                             (12,1,'brake-lines',       'Спирачни тръби и маркучи',                    NULL,NULL, 5),
                                                                                             (12,1,'brake-abs',         'ABS помпа и хидравличен блок',                NULL,NULL, 6),
                                                                                             (12,1,'brake-epb',         'Електронна ръчна спирачка (EPB)',              NULL,NULL, 7),
                                                                                             (12,1,'brake-pedal',       'Педал на спирачката',                         NULL,NULL, 8);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (13,1,'body-front-bumper', 'Предна броня',                                  NULL,NULL, 1),
                                                                                             (13,1,'body-rear-bumper',  'Задна броня',                                   NULL,NULL, 2),
                                                                                             (13,1,'body-hood',         'Преден капак (Качулка)',                        NULL,NULL, 3),
                                                                                             (13,1,'body-trunk',        'Заден капак (Багажник)',                        NULL,NULL, 4),
                                                                                             (13,1,'body-door-front',   'Предна врата',                                  NULL,NULL, 5),
                                                                                             (13,1,'body-door-rear',    'Задна врата',                                   NULL,NULL, 6),
                                                                                             (13,1,'body-fender',       'Калник',                                        NULL,NULL, 7),
                                                                                             (13,1,'body-roof',         'Покрив',                                        NULL,NULL, 8),
                                                                                             (13,1,'body-mirrors',      'Странични огледала',                           NULL,NULL, 9),
                                                                                             (13,1,'body-lights-front', 'Предни светлини / Фарове',                    NULL,NULL,10),
                                                                                             (13,1,'body-lights-rear',  'Задни светлини / Стопове',                    NULL,NULL,11),
                                                                                             (13,1,'body-windshield',   'Предно стъкло и чистачки',                    NULL,NULL,12),
                                                                                             (13,1,'body-seals',        'Уплътнения на вратите и прозорците',          NULL,NULL,13);

INSERT INTO component_groups (group_id,car_id,code,name_bg,diagram_path,sort_order) VALUES
                                                                                             (14,1,'trim-dashboard',    'Табло и арматурен панел',                      NULL,NULL, 1),
                                                                                             (14,1,'trim-seats',        'Седалки',                                       NULL,NULL, 2),
                                                                                             (14,1,'trim-console',      'Централна конзола',                             NULL,NULL, 3),
                                                                                             (14,1,'trim-door-panels',  'Тапицерия на вратите',                         NULL,NULL, 4),
                                                                                             (14,1,'trim-carpet',       'Мокет и шумоизолация',                         NULL,NULL, 5),
                                                                                             (14,1,'trim-headliner',    'Тавaн (тапицерия)',                            NULL,NULL, 6),
                                                                                             (14,1,'trim-steering-col', 'Облицовка на кормилната колона',               NULL,NULL, 7),
                                                                                             (14,1,'trim-ac',           'Климатик и управление',                        NULL,NULL, 8),
                                                                                             (14,1,'trim-instruments',  'Табло с инструменти / Комбиприбор',           NULL,NULL, 9),
                                                                                             (14,1,'trim-infotainment', 'iDrive / Мултимедия / Навигация',             NULL,NULL,10),
                                                                                             (14,1,'trim-sunroof',      'Панорамен люк',                                NULL,NULL,11),
                                                                                             (14,1,'trim-seatbelts',    'Предпазни колани',                             NULL,NULL,12);

-- ═══════════════════════════════════════════════════════════════
--  USERS (потребители)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE users (
                       id           BIGINT        AUTO_INCREMENT PRIMARY KEY,
                       email        VARCHAR(100)  NOT NULL UNIQUE,
                       password_hash VARCHAR(255) NOT NULL,
                       full_name    VARCHAR(100)  NOT NULL,
                       created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                       enabled      BOOLEAN       DEFAULT TRUE
);

-- ═══════════════════════════════════════════════════════════════
--  SEARCH_HISTORY (история на търсения)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE search_history (
                                id         BIGINT        AUTO_INCREMENT PRIMARY KEY,
                                user_id    BIGINT        NOT NULL,
                                vin        VARCHAR(17)   NOT NULL,
                                searched_at TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                                INDEX idx_user_vin (user_id, vin),
                                INDEX idx_searched_at (searched_at),
                                CONSTRAINT fk_sh_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ═══════════════════════════════════════════════════════════════
--  USER_GARAGE (гараж на потребител)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE user_garage (
                             id         BIGINT        AUTO_INCREMENT PRIMARY KEY,
                             user_id    BIGINT        NOT NULL,
                             vin        VARCHAR(17)   NOT NULL,
                             added_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
                             UNIQUE KEY uk_user_vin (user_id, vin),
                             INDEX idx_vin (vin),
                             CONSTRAINT fk_ug_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================================
--  UPDATE ENGINE COMPONENT GROUPS WITH BULGARIAN DIAGRAM PATHS
-- ============================================================

-- Engine Block
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Блок на двигателя.jpg' 
WHERE code = 'eng-block';

-- Crankshaft and Pistons  
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Колянов вал и бутала.jpg' 
WHERE code = 'eng-crankshaft';

-- Timing Cover
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Капак на разпределението и уплътнение.jpg' 
WHERE code = 'eng-timing-cover';

-- Timing Chain
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Верига на разпределението.jpg' 
WHERE code = 'eng-timing-chain';

-- Cylinder Head
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Глава на цилиндрите.jpg' 
WHERE code = 'eng-cylinder-head';

-- Valvetrain/VANOS
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Клапанен механизъм-VANOS.jpg' 
WHERE code = 'eng-valvetrain';

-- Oil Pan
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Маслена вана.jpg' 
WHERE code = 'eng-oil-pan';

-- Oil Pump
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Маслена помпа.jpg' 
WHERE code = 'eng-oil-pump';

-- Oil Filter
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Маслен филтър и корпус.jpg' 
WHERE code = 'eng-oil-filter';

-- Intake Manifold
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Всмукателен колектор.jpg' 
WHERE code = 'eng-intake';

-- Turbocharger
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Турбокомпресор.jpg' 
WHERE code = 'eng-turbo';

-- Engine Mounts
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Тампони на двигателя.jpg' 
WHERE code = 'eng-mounts';

-- Vacuum System
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Вакуумна система.jpg' 
WHERE code = 'eng-vacuum';

-- Belt Drive
UPDATE component_groups 
SET diagram_path = '/images/diagrams/Пистов ремък и обтегачи.jpg' 
WHERE code = 'eng-belt-drive';

-- ============================================================
--  ENGINE BLOCK PARTS DATA (Component Group ID = 1)
--  Source: RealOEM.com - BMW F30 340i - Engine Block
-- ============================================================

-- Get component_group_id for engine block
SET @engine_block_id = (SELECT id FROM component_groups WHERE code = 'eng-block');

INSERT INTO parts (component_group_id, car_id, diagram_number, name_bg, oe_number) VALUES
(@engine_block_id, 1, 1, 'Вално уплътнение', '11118664905'),
(@engine_block_id, 1, 2, 'Вално уплътнение', '11148664904'),
(@engine_block_id, 1, 3, 'Релектор', '11148605104'),
(@engine_block_id, 1, 4, 'Електромагнитен клапан (SOLV)', '11417639993'),
(@engine_block_id, 1, 5, 'Датчик за налягане на маслото', '12618614494'),
(@engine_block_id, 1, 6, 'Датчик на колянов вал', '13627806782'),
(@engine_block_id, 1, 7, 'Обратен клапан', '11667620923'),
(@engine_block_id, 1, 8, 'Датчик за детонация', '13627636937'),
(@engine_block_id, 1, 9, 'Контакт', '11118619408'),
(@engine_block_id, 1, 10, 'Контакт', '11118629123'),
(@engine_block_id, 1, 11, 'Маслен дефлектор', '11137643045'),
(@engine_block_id, 1, 12, 'Мазателна дюза', '11427634186'),
(@engine_block_id, 1, 13, 'Държател', '11518631090'),
(@engine_block_id, 1, 14, 'Слеп капак', '11117536143'),
(@engine_block_id, 1, 15, 'Щифт', '11112245180'),
(@engine_block_id, 1, 16, 'ASA-болт', '11418612615'),
(@engine_block_id, 1, 17, 'Звездовиден винт', '07119907490'),
(@engine_block_id, 1, 18, 'Заклепален винт', '07119906651'),
(@engine_block_id, 1, 19, 'Звездовиден винт', '13629907870'),
(@engine_block_id, 1, 20, 'Винт с шайба', '07129904707'),
(@engine_block_id, 1, 21, 'Датчик за температура на охладител/масло', '13627580635'),
(@engine_block_id, 1, 22, 'О-пръстен', '13628658854');

-- ============================================================
--  CRANKSHAFT AND PISTONS PARTS DATA (Component Group ID = 2)
--  Source: RealOEM.com - BMW F30 340i - Crankshaft and Pistons
-- ============================================================

-- Get component_group_id for crankshaft and pistons
SET @crankshaft_id = (SELECT id FROM component_groups WHERE code = 'eng-crankshaft');

INSERT INTO parts (component_group_id, car_id, diagram_number, name_bg, oe_number) VALUES
(@crankshaft_id, 1, 1, 'Част не се доставя отделно', '00000000000'),
(@crankshaft_id, 1, 2, 'Лагерна обвивка, синя', '11218588650'),
(@crankshaft_id, 1, 2, 'Лагерна обвивка, зелена', '11218588651'),
(@crankshaft_id, 1, 2, 'Лагерна обвивка, кафява', '11218588652'),
(@crankshaft_id, 1, 3, 'Насочваща лагерна обвивка, синя', '11218588658'),
(@crankshaft_id, 1, 4, 'Насочваща лагерна обвивка 1, синя', '11218588662'),
(@crankshaft_id, 1, 4, 'Насочваща лагерна обвивка 2, зелена', '11218588663'),
(@crankshaft_id, 1, 4, 'Насочваща лагерна обвивка 3, кафява', '11218588664'),
(@crankshaft_id, 1, 5, 'Лагерна обвивка, синя', '11218595888'),
(@crankshaft_id, 1, 5, 'Лагерна обвивка, зелена', '11218595889'),
(@crankshaft_id, 1, 5, 'Лагерна обвивка, кафява', '11218595890'),
(@crankshaft_id, 1, 6, 'Лагерна обвивка', '11247620969'),
(@crankshaft_id, 1, 7, 'Лагерна обвивка', '11247620970'),
(@crankshaft_id, 1, 8, 'Щифт', '11217797978'),
(@crankshaft_id, 1, 9, 'ASA-болт', '11118604584');

-- ============================================================
--  TIMING COVER AND GASKET PARTS DATA (Component Group ID = 3)
--  Source: RealOEM.com - BMW F30 340i - Timing Cover and Gasket
-- ============================================================

-- Get component_group_id for timing cover and gasket
SET @timing_cover_id = (SELECT id FROM component_groups WHERE code = 'eng-timing-cover');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@timing_cover_id, 1, 'Капак на главата на цилиндрите', '11127645173', 1, ''),
(@timing_cover_id, 2, 'Профилно уплътнение, капак на главата, външно', '11128621951', 1, ''),
(@timing_cover_id, 3, 'Профилно уплътнение за капак, вътрешно', '11128638124', 1, ''),
(@timing_cover_id, 4, 'Профилна проставка', '11128633750', 1, ''),
(@timing_cover_id, 5, 'ASA-болт', '11128642280', 21, ''),
(@timing_cover_id, 6, 'Амортизаторен ограничител', '11127614138', 4, ''),
(@timing_cover_id, 7, 'Датчик за положение на разпределителния вал', '13627633958', 2, ''),
(@timing_cover_id, 8, 'О-пръстен', '13628658854', 2, '18,2X2,5'),
(@timing_cover_id, 9, 'Torx-винт за пластмаса', '07119907480', 2, 'TS5X20'),
(@timing_cover_id, 10, 'Закачащ скоба', '11127648915', 4, ''),
(@timing_cover_id, 10, 'Закачащ скоба', '11128642177', 4, ''),
(@timing_cover_id, 11, 'Изпълнителен механизъм, VANOS', '11367614288', 2, ''),
(@timing_cover_id, 12, 'Уплътнение', '11365A65AB5', 2, ''),
(@timing_cover_id, 13, 'Надпис за система високо налягане гориво', '71227598859', 1, ''),
(@timing_cover_id, 14, 'Етикет "Запалителна бобина"', '71227618790', 1, ''),
(@timing_cover_id, 15, 'Амортизатор гума', '13537639983', 1, ''),
(@timing_cover_id, 16, 'Държач за кабели', '07146976165', 1, ''),
(@timing_cover_id, 17, 'Кабелна скоба', '11787549563', 1, ''),
(@timing_cover_id, 17, 'Скоба', '07147568538', 1, '15-19'),
(@timing_cover_id, 18, 'Капак за масло', '11128655331', 1, ''),
(@timing_cover_id, 19, 'Ремонтен комплект за клапан за налягане B58', '11121025447', 1, '');

-- ============================================================
--  TIMING CHAIN PARTS DATA (Component Group ID = 4)
--  Source: RealOEM.com - BMW F30 340i - Timing Chain
-- ============================================================

-- Get component_group_id for timing chain
SET @timing_chain_id = (SELECT id FROM component_groups WHERE code = 'eng-timing-chain');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@timing_chain_id, 1, 'Верига', '13528648731', 1, ''),
(@timing_chain_id, 2, 'Зъбно колело', '13528642165', 1, ''),
(@timing_chain_id, 3, 'Лагерен винт', '13527617486', 1, 'M12X1'),
(@timing_chain_id, 4, 'Направляваща релса', '13527636186', 1, ''),
(@timing_chain_id, 5, 'Натягач на верига', '13527636185', 1, ''),
(@timing_chain_id, 6, 'Натягач на верига', '13527797905', 1, ''),
(@timing_chain_id, 7, 'ASA-болт', '13527800396', 2, 'M6X22-Z1'),
(@timing_chain_id, 8, 'Лагерна шийка, картер', '13527797908', 3, '');

-- ============================================================
--  CYLINDER HEAD PARTS DATA (Component Group ID = 5)
--  Source: RealOEM.com - BMW F30 340i - Cylinder Head
-- ============================================================

-- Get component_group_id for cylinder head
SET @cylinder_head_id = (SELECT id FROM component_groups WHERE code = 'eng-cylinder-head');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@cylinder_head_id, 1, 'Глава на цилиндрите с клапанен механизъм', '11128482779', 1, 'only in conjunction with'),
(@cylinder_head_id, 1, 'Щифт', '07119942082', 2, '4X16MM'),
(@cylinder_head_id, 2, 'Проставка на глава на цилиндрите', '11128654268', 1, '0,70MM'),
(@cylinder_head_id, 2, 'Проставка на глава на цилиндрите', '11128654269', 1, '1,00MM (+0,3)'),
(@cylinder_head_id, 3, 'Болт на глава на цилиндрите', '11128644674', 14, 'M11X188'),
(@cylinder_head_id, 4, 'Шайба', '11127583138', 14, ''),
(@cylinder_head_id, 5, 'ASA-болт', '07119907475', 5, 'M8X40'),
(@cylinder_head_id, 6, 'Част не се доставя отделно', '00000000000', 1, ''),
(@cylinder_head_id, 7, 'Въздухоизпускателна връзка с О-пръстен', '11128626622', 1, ''),
(@cylinder_head_id, 8, 'Примка', '11127638711', 1, ''),
(@cylinder_head_id, 9, 'Изпълнителен механизъм', '11377643073', 2, ''),
(@cylinder_head_id, 10, 'Датчик за температура, глава на цилиндрите', '13628649765', 1, ''),
(@cylinder_head_id, 11, 'Вално уплътнение', '11378662525', 1, 'Observe repair manual.Changed tightening process'),
(@cylinder_head_id, 12, 'Заклепален винт', '07119907886', 2, 'M6X35-8.8'),
(@cylinder_head_id, 12, 'Заклепален винт', '07119909683', 2, 'M6X35-10.9'),
(@cylinder_head_id, 13, 'ISA винт', '07129905536', 2, 'M6X16-8.8-ZNNIV'),
(@cylinder_head_id, 14, 'Шестостен винт с шайба', '07119905739', 2, 'M8X22'),
(@cylinder_head_id, 15, 'Щифт', '11127606504', 2, 'D=7,5MM'),
(@cylinder_head_id, 16, 'Щифт', '11112245180', 2, 'D=14,5MM'),
(@cylinder_head_id, 17, 'ASA-спирален болт', '11127647711', 7, 'M7X47-10.9-PHR');

-- ============================================================
--  VALVETRAIN/VANOS PARTS DATA (Component Group ID = 6)
--  Source: RealOEM.com - BMW F30 340i - Valvetrain/VANOS
-- ============================================================

-- Get component_group_id for valvetrain/VANOS
SET @valvetrain_id = (SELECT id FROM component_groups WHERE code = 'eng-valvetrain');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@valvetrain_id, 1, 'Верига на разпределението', '11318648729', 1, ''),
(@valvetrain_id, 2, 'Зъбно колело', '13528642165', 1, ''),
(@valvetrain_id, 3, 'Лагерен винт', '13527617486', 1, 'M12X1'),
(@valvetrain_id, 4, 'Регулираща единица, разпределителен вал засмукване', '11368684920', 1, 'Observe Service Information Bulletin 64122020'),
(@valvetrain_id, 5, 'Регулираща единица, разпределителен вал изпускане', '11368684921', 1, ''),
(@valvetrain_id, 7, 'Изпълнителен механизъм, VANOS', '11367614288', 2, ''),
(@valvetrain_id, 8, 'Уплътнение', '11365A65AB5', 2, ''),
(@valvetrain_id, 9, 'Натягач на верига', '11317617472', 1, ''),
(@valvetrain_id, 10, 'Направляваща релса', '11317617489', 1, ''),
(@valvetrain_id, 11, 'Натягач на верига', '11317617475', 1, ''),
(@valvetrain_id, 12, 'Пръстенна проставка', '11317631972', 1, 'A22X27'),
(@valvetrain_id, 13, 'Плъзгаща релса', '11317617474', 1, 'Mounting bolts included in the accessories'),
(@valvetrain_id, 14, 'Лагерна шийка, глава на цилиндрите', '11317797900', 2, ''),
(@valvetrain_id, 15, 'Лагерна шийка, картер', '13527797908', 1, ''),
(@valvetrain_id, 16, 'Заклепален винт', '07119907139', 2, 'M6X16'),
(@valvetrain_id, 17, 'Централен клапан VANOS', '11368696446', 2, 'M21');

-- ============================================================
--  OIL PAN PARTS DATA (Component Group ID = 7)
--  Source: RealOEM.com - BMW F30 340i - Oil Pan
-- ============================================================

-- Get component_group_id for oil pan
SET @oil_pan_id = (SELECT id FROM component_groups WHERE code = 'eng-oil-pan');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@oil_pan_id, 1, 'Маслена вана', '11138580126', 1, 'Required for repair'),
(@oil_pan_id, 1, 'Loctite 5970 течно уплътнение', '83190404517', 1, '50ML'),
(@oil_pan_id, 2, 'Винт-капак', '11137535106', 1, 'M12X16'),
(@oil_pan_id, 3, 'Пръстенна проставка', '07119963132', 1, 'A12X16-CU'),
(@oil_pan_id, 4, 'Loctite 5970 течно уплътнение', '83190404517', 1, '50ML'),
(@oil_pan_id, 5, 'ASA-болт', '11138592611', 22, 'M8X30'),
(@oil_pan_id, 6, 'Torx винт', '11137800625', 2, 'M8X110'),
(@oil_pan_id, 7, 'ASA-болт', '23001222887', 3, 'M8X50-8.8-ZNS3'),
(@oil_pan_id, 8, 'Датчик за ниво на маслото', '12618638755', 1, '132,8MM'),
(@oil_pan_id, 9, 'Проставка', '12617604790', 1, ''),
(@oil_pan_id, 10, 'Шестостен гайка с плоча', '07119905544', 3, 'M6-8-ZNNIV SI'),
(@oil_pan_id, 11, 'Спирален болт', '07129904544', 3, 'M6X30-ZNNIV SI'),
(@oil_pan_id, 12, 'Слеп капак', '11117536143', 1, '');

-- ============================================================
--  OIL PUMP PARTS DATA (Component Group ID = 8)
--  Source: RealOEM.com - BMW F30 340i - Oil Pump
-- ============================================================

-- Get component_group_id for oil pump
SET @oil_pump_id = (SELECT id FROM component_groups WHERE code = 'eng-oil-pump');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@oil_pump_id, 1, 'Маслена помпа', '11417643046', 1, 'Build level up to 07/2018 has a single-surface connection and as of 07/2018, it has a two-surface connection'),
(@oil_pump_id, 1, 'Маслена помпа', '11417643046', 1, '07/2018'),
(@oil_pump_id, 2, 'Всмукателна тръба', '11417643047', 1, ''),
(@oil_pump_id, 3, 'Верига', '11418482270', 1, ''),
(@oil_pump_id, 4, 'Зъбно колело', '11418600425', 1, 'Build level up to 07/2018 has a single-surface connection and as of 07/2018, it has a two-surface connection'),
(@oil_pump_id, 4, 'Зъбно колело', '11418600425', 1, '07/2018'),
(@oil_pump_id, 5, 'ISA винт', '11417823426', 1, 'M8X35-PHR'),
(@oil_pump_id, 6, 'ASA-болт', '11418612615', 4, 'M8X35'),
(@oil_pump_id, 7, 'Шестостен винт с шайба', '07119905400', 2, 'M6X25-ZNNIV SI'),
(@oil_pump_id, 8, 'Пръстенна проставка', '11419494956', 1, 'ÖLPUMPE');

-- ============================================================
--  OIL FILTER AND HOUSING PARTS DATA (Component Group ID = 9)
--  Source: RealOEM.com - BMW F30 340i - Oil Filter and Housing
-- ============================================================

-- Get component_group_id for oil filter and housing
SET @oil_filter_id = (SELECT id FROM component_groups WHERE code = 'eng-oil-filter');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@oil_filter_id, 1, 'Маслен филтър', '11428583895', 1, ''),
(@oil_filter_id, 2, 'Комплект елемент на маслен филтър', '11427826799', 1, '05/2025'),
(@oil_filter_id, 2, 'Комплект елемент на маслен филтър', '11425B4C845', 1, ''),
(@oil_filter_id, 3, 'Капак на маслен филтър', '11427926064', 1, ''),
(@oil_filter_id, 4, 'Топлообменник', '11428583901', 1, ''),
(@oil_filter_id, 5, 'Комплект проставки', '11428583896', 1, ''),
(@oil_filter_id, 6, 'Комплект проставки', '11428583897', 1, ''),
(@oil_filter_id, 7, 'Заклепален винт', '07119907144', 6, 'M6X16'),
(@oil_filter_id, 8, 'ASA-болт', '11428585734', 6, 'M6X49,5');

-- ============================================================
--  INTAKE MANIFOLD PARTS DATA (Component Group ID = 10)
--  Source: RealOEM.com - BMW F30 340i - Intake Manifold
-- ============================================================

-- Get component_group_id for intake manifold
SET @intake_manifold_id = (SELECT id FROM component_groups WHERE code = 'eng-intake');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@intake_manifold_id, 1, 'Система на всмукателен колектор', '11618603913', 1, 'Note Repair Manual'),
(@intake_manifold_id, 2, 'Уплътнение за всмукателна система', '11618637800', 6, ''),
(@intake_manifold_id, 3, 'Накрайник винт', '11618583174', 7, 'M6'),
(@intake_manifold_id, 4, 'Опора, предна', '11618602078', 1, ''),
(@intake_manifold_id, 5, 'Опора, задна', '11618602082', 1, ''),
(@intake_manifold_id, 6, 'Звездовиден винт', '07119908752', 2, 'M6X25'),
(@intake_manifold_id, 7, 'Звездовиден винт', '07119908518', 4, 'BM6X16-U1-8.8'),
(@intake_manifold_id, 8, 'T-map датчик', '13628637900', 1, '2,5 BAR'),
(@intake_manifold_id, 9, 'Винт', '07129907489', 1, '6X20'),
(@intake_manifold_id, 10, 'Маручна скоба', '17128632635', 1, ''),
(@intake_manifold_id, 11, 'Шестостен винт с шайба', '07119906203', 1, 'M3X16-C-U2-ZNS3'),
(@intake_manifold_id, 12, 'Защита на ръб', '11618663489', 1, '');

-- ============================================================
--  TURBOCHARGER PARTS DATA (Component Group ID = 11)
--  Source: RealOEM.com - BMW F30 340i - Turbocharger
-- ============================================================

-- Get component_group_id for turbocharger
SET @turbocharger_id = (SELECT id FROM component_groups WHERE code = 'eng-turbo');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@turbocharger_id, 1, 'Турбокомпресор', '11659423787', 1, 'only in conjunction with'),
(@turbocharger_id, 1, 'Добавка за турбокомпресор дизел/бензин', '83195B305D6', 1, '17ML'),
(@turbocharger_id, 1, 'Монтажен комплект изпускателна система турбокомпресор', '11652471552', 1, 'VALUE PARTS'),
(@turbocharger_id, 2, 'Проставка за изпускателен колектор', '11657643149', 1, ''),
(@turbocharger_id, 3, 'Комплект изпълнителен механизъм клапан Wastegate', '11658662676', 1, ''),
(@turbocharger_id, 4, 'Плъзгаща лента', '11657643151', 1, ''),
(@turbocharger_id, 5, 'Фланецова гайка с пружинни шайби', '11658670587', 7, 'M7'),
(@turbocharger_id, 6, 'Шестостен винт', '11658623438', 7, 'M7X27'),
(@turbocharger_id, 7, 'Опора', '11657643148', 1, ''),
(@turbocharger_id, 8, 'ISA винт', '11657609303', 1, 'M8X25'),
(@turbocharger_id, 9, 'ISA винт', '11657609961', 2, 'M8X20-10.9 ZNS3'),
(@turbocharger_id, 10, 'Винтова скоба', '18328612537', 1, 'D=135MM'),
(@turbocharger_id, 11, 'Пръстенна проставка', '18328612538', 1, ''),
(@turbocharger_id, 12, 'Клемна лента', '11657643150', 1, '');

-- ============================================================
--  ENGINE MOUNTS PARTS DATA (Component Group ID = 12)
--  Source: RealOEM.com - BMW F30 340i - Engine Mounts
-- ============================================================

-- Get component_group_id for engine mounts
SET @engine_mounts_id = (SELECT id FROM component_groups WHERE code = 'eng-mounts');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@engine_mounts_id, 1, 'Опорна скоба на двигателя, лява', '22116859011', 1, ''),
(@engine_mounts_id, 2, 'Опорна скоба на двигателя, дясна', '22116859012', 1, ''),
(@engine_mounts_id, 3, 'Тампон на двигателя, ляв', '22116787659', 1, 'Required for repair'),
(@engine_mounts_id, 3, 'Torx винт', '31106794380', 3, 'M8X33-8.8-ZNS3'),
(@engine_mounts_id, 3, 'Фланецова гайка', '07119904670', 1, 'M10-10-ZNS3'),
(@engine_mounts_id, 4, 'Тампон на двигателя, десен', '22116855460', 1, 'Required for repair'),
(@engine_mounts_id, 4, 'Torx винт', '31106794380', 3, 'M8X33-8.8-ZNS3'),
(@engine_mounts_id, 4, 'Фланецова гайка', '07119904670', 1, 'M10-10-ZNS3'),
(@engine_mounts_id, 5, 'Звездовиден винт', '07119908517', 8, 'BM10X40-U1-8.8'),
(@engine_mounts_id, 6, 'Torx винт', '31106794380', 6, 'M8X33-8.8-ZNS3'),
(@engine_mounts_id, 7, 'Фланецова гайка', '07119904670', 2, 'M10-10-ZNS3');

-- ============================================================
--  VACUUM SYSTEM PARTS DATA (Component Group ID = 13)
--  Source: RealOEM.com - BMW F30 340i - Vacuum System
-- ============================================================

-- Get component_group_id for vacuum system
SET @vacuum_system_id = (SELECT id FROM component_groups WHERE code = 'eng-vacuum');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@vacuum_system_id, 1, 'Обратен клапан', '11667620923', 1, ''),
(@vacuum_system_id, 2, 'Вакуумна тръба', '11665A09C60', 1, ''),
(@vacuum_system_id, 3, 'Вакуумна тръба с обратен клапан', '11667613026', 1, ''),
(@vacuum_system_id, 5, 'Капак', '11667803829', 1, '');

-- ============================================================
--  BELT DRIVE PARTS DATA (Component Group ID = 14)
--  Source: RealOEM.com - BMW F30 340i - Belt Drive
-- ============================================================

-- Get component_group_id for belt drive
SET @belt_drive_id = (SELECT id FROM component_groups WHERE code = 'eng-belt-drive');

INSERT INTO parts (component_group_id, diagram_number, name_bg, oe_number, qty, notes_bg) VALUES
(@belt_drive_id, 1, 'Ребрист V-ремък', '11288613707', 1, '6 PK X 1155'),
(@belt_drive_id, 2, 'Механичен обтегач на ремък', '11288580360', 1, ''),
(@belt_drive_id, 3, 'Шестостен винт', '07119908571', 3, '');

--- Get component_group_id for engine wiring harness
SET @wiring_id = (SELECT id FROM component_groups WHERE code = 'elec-wiring');

INSERT INTO parts (component_group_id, car_id, diagram_number, name_bg, oe_number) VALUES
(@wiring_id, 1, 1, 'Кабелен сноп, сензорен модул двигателя 1', '12518631656'),
(@wiring_id, 1, 2, 'Кабелен сноп, сензорен модул двигателя 2', '12518631665'),
(@wiring_id, 1, 3, 'Кабел за инжекторна/запалителна клапа', '12518631668'),
(@wiring_id, 1, 8, 'Кабелен сноп, трансмисионен модул двигателя', '12538631671');
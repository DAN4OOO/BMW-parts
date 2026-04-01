-- ============================================================
--  BMW Parts Catalog — F30 340i Complete Schema
--  Всички имена на български
--  Run: mysql -u root -p < schema.sql
-- ============================================================

DROP DATABASE IF EXISTS bmw_parts;
CREATE DATABASE bmw_parts CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bmw_parts;

-- ── Cars ──────────────────────────────────────────────────────
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

-- ── Part Groups ───────────────────────────────────────────────
CREATE TABLE part_groups (
    id         BIGINT       AUTO_INCREMENT PRIMARY KEY,
    code       VARCHAR(60)  NOT NULL UNIQUE,
    name_bg    VARCHAR(160) NOT NULL,
    icon       VARCHAR(10)  NOT NULL DEFAULT '⚙️',
    sort_order INT          NOT NULL DEFAULT 0
);

-- ── Component Groups ──────────────────────────────────────────
CREATE TABLE component_groups (
    id             BIGINT       AUTO_INCREMENT PRIMARY KEY,
    group_id       BIGINT       NOT NULL,
    code           VARCHAR(100) NOT NULL UNIQUE,
    name_bg        VARCHAR(200) NOT NULL,
    diagram_path   VARCHAR(300),
    description_bg TEXT,
    realoem_ref    VARCHAR(60),
    sort_order     INT          NOT NULL DEFAULT 0,
    CONSTRAINT fk_cg_group FOREIGN KEY (group_id) REFERENCES part_groups(id)
);

-- ── Parts ─────────────────────────────────────────────────────
CREATE TABLE parts (
    id                 BIGINT       AUTO_INCREMENT PRIMARY KEY,
    component_group_id BIGINT       NOT NULL,
    diagram_number     INT          NOT NULL,
    name_bg            VARCHAR(255) NOT NULL,
    oe_number          VARCHAR(60)  NOT NULL,
    qty                INT          NOT NULL DEFAULT 1,
    notes_bg           TEXT,
    CONSTRAINT fk_p_cg FOREIGN KEY (component_group_id) REFERENCES component_groups(id)
);

-- ── Prices ────────────────────────────────────────────────────
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

-- ═══════════════════════════════════════════════════════════════
--  АВТОМОБИЛ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO cars (vin,make,model,series,year,body,engine_code,engine_desc,fuel,gearbox)
VALUES ('WBA8B3C55JK385192','BMW','3 Series','F30 340i',2018,
        'Седан','B58B30','3.0L Inline-6 Turbo 326к.с.','Бензин','8-степ. автоматична ZF8HP');

-- ═══════════════════════════════════════════════════════════════
--  ОСНОВНИ ГРУПИ
-- ═══════════════════════════════════════════════════════════════
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

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 1. ДВИГАТЕЛ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(1,'eng-block',          'Блок на двигателя',                       NULL,NULL, 1),
(1,'eng-crankshaft',     'Колянов вал и бутала',                    NULL,NULL, 2),
(1,'eng-timing-cover',   'Капак на разпределението и уплътнение',   NULL,NULL, 3),
(1,'eng-timing-chain',   'Верига на разпределението',               NULL,NULL, 4),
(1,'eng-cylinder-head',  'Глава на цилиндрите',                     NULL,NULL, 5),
(1,'eng-valvetrain',     'Клапанен механизъм / VANOS',              NULL,NULL, 6),
(1,'eng-oil-pan',        'Маслена вана',                            NULL,NULL, 7),
(1,'eng-oil-pump',       'Маслена помпа',                           NULL,NULL, 8),
(1,'eng-oil-filter',     'Маслен филтър и корпус',                  NULL,NULL, 9),
(1,'eng-intake',         'Всмукателен колектор',                    NULL,NULL,10),
(1,'eng-turbo',          'Турбокомпресор',                          NULL,NULL,11),
(1,'eng-mounts',         'Тампони на двигателя',                    NULL,NULL,12),
(1,'eng-vacuum',         'Вакуумна система',                        NULL,NULL,13),
(1,'eng-belt-drive',     'Пистов ремък и обтегачи',                NULL,NULL,14);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 2. ЕЛЕКТРИЧЕСКА СИСТЕМА НА ДВИГАТЕЛЯ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(2,'elec-alternator',    'Генератор',                                      NULL,NULL, 1),
(2,'elec-starter',       'Стартер',                                        NULL,NULL, 2),
(2,'elec-ignition',      'Бобини и свещи за запалване',                   NULL,NULL, 3),
(2,'elec-crank-sensor',  'Сензор за положение на коляновия вал',           NULL,NULL, 4),
(2,'elec-cam-sensor',    'Сензор за разпредвал',                          NULL,NULL, 5),
(2,'elec-map-sensor',    'Сензор за налягане на всмукателния колектор',    NULL,NULL, 6),
(2,'elec-lambda',        'Ламбда сонда / О2 сензор',                      NULL,NULL, 7),
(2,'elec-temp-sensor',   'Сензор за температура на охладителя',           NULL,NULL, 8),
(2,'elec-battery',       'Акумулатор и IBS сензор',                       NULL,NULL, 9),
(2,'elec-ecu',           'Управляващ блок на двигателя (DME)',             NULL,NULL,10),
(2,'elec-wiring',        'Кабелен сноп на двигателя',                     NULL,NULL,11);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 3. СИСТЕМА ЗА ПОДГОТОВКА НА ГОРИВОТО
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(3,'fuel-injectors',     'Горивни инжектори',                             NULL,NULL, 1),
(3,'fuel-hp-pump',       'Горивна помпа с високо налягане',               NULL,NULL, 2),
(3,'fuel-pressure-reg',  'Регулатор на налягането на горивото',           NULL,NULL, 3),
(3,'fuel-rail',          'Горивна рейка',                                 NULL,NULL, 4),
(3,'fuel-throttle',      'Дросел клапа',                                  NULL,NULL, 5),
(3,'fuel-air-filter',    'Въздушен филтър и кутия',                      NULL,NULL, 6),
(3,'fuel-intercooler',   'Интеркулер (охладител на наддувния въздух)',    NULL,NULL, 7),
(3,'fuel-crankcase',     'Вентилация на картера',                         NULL,NULL, 8);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 4. ГОРИВОСНАБДЯВАНЕ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(4,'supply-tank',        'Горивен резервоар',                             NULL,NULL, 1),
(4,'supply-lp-pump',     'Горивна помпа ниско налягане (в резервоара)',   NULL,NULL, 2),
(4,'supply-fuel-filter', 'Горивен филтър',                                NULL,NULL, 3),
(4,'supply-filler',      'Гърловина за зареждане с гориво',              NULL,NULL, 4),
(4,'supply-lines',       'Горивопроводи',                                 NULL,NULL, 5),
(4,'supply-evap',        'EVAP система (абсорбатор с активен въглен)',    NULL,NULL, 6);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 5. РАДИАТОР / ОХЛАДИТЕЛНА СИСТЕМА
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(5,'rad-radiator',       'Радиатор',                                      NULL,NULL, 1),
(5,'rad-water-pump',     'Водна помпа и термостат',                       NULL,NULL, 2),
(5,'rad-fan',            'Електрически вентилатор на радиатора',          NULL,NULL, 3),
(5,'rad-expansion',      'Разширителен съд',                              NULL,NULL, 4),
(5,'rad-hoses',          'Охладителни маркучи',                           NULL,NULL, 5),
(5,'rad-oil-cooler',     'Маслен охладител',                              NULL,NULL, 6),
(5,'rad-ac-condenser',   'Кондензатор на климатика',                      NULL,NULL, 7);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 6. ИЗПУСКАТЕЛНА СИСТЕМА
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(6,'exh-manifold',       'Изпускателен колектор',                         NULL,NULL, 1),
(6,'exh-catalytic',      'Катализатор',                                   NULL,NULL, 2),
(6,'exh-dpf',            'Сажден / Бензинов частичен филтър (OPF)',       NULL,NULL, 3),
(6,'exh-mid-pipe',       'Средна тръба',                                  NULL,NULL, 4),
(6,'exh-muffler',        'Заден заглушител',                              NULL,NULL, 5),
(6,'exh-hangers',        'Окачване на изпускателната система',            NULL,NULL, 6);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 7. СЪЕДИНИТЕЛ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(7,'clutch-assembly',    'Комплект съединител (диск и притискателна плоча)',NULL,NULL, 1),
(7,'clutch-flywheel',    'Двумасов маховик',                              NULL,NULL, 2),
(7,'clutch-bearing',     'Лагер на съединителя',                          NULL,NULL, 3),
(7,'clutch-master-cyl',  'Главен цилиндър на съединителя',                NULL,NULL, 4),
(7,'clutch-slave-cyl',   'Работен цилиндър на съединителя',               NULL,NULL, 5),
(7,'clutch-pedal',       'Педал на съединителя',                          NULL,NULL, 6);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 8. СКОРОСТНА КУТИЯ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(8,'gearbox-case',       'Корпус на скоростната кутия ZF8HP',             NULL,NULL, 1),
(8,'gearbox-torque-conv','Хидравличен съединител (Торкконвертор)',         NULL,NULL, 2),
(8,'gearbox-oil-pan',    'Маслена вана на скоростната кутия',             NULL,NULL, 3),
(8,'gearbox-valve-body', 'Хидравличен разпределителен блок',              NULL,NULL, 4),
(8,'gearbox-mounts',     'Тампони на скоростната кутия',                  NULL,NULL, 5),
(8,'gearbox-propshaft',  'Карданен вал',                                  NULL,NULL, 6),
(8,'gearbox-halfshaft',  'Полуоси',                                       NULL,NULL, 7),
(8,'gearbox-selector',   'Лост за избор на предавка (Shift by Wire)',     NULL,NULL, 8);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 9. ПРЕДНА ОС
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(9,'front-strut',        'Преден амортисьор / Макферсон стрът',           NULL,NULL, 1),
(9,'front-spring',       'Предна пружина',                                NULL,NULL, 2),
(9,'front-lower-arm',    'Долен носач предна ос',                         NULL,NULL, 3),
(9,'front-upper-arm',    'Горен носач предна ос',                         NULL,NULL, 4),
(9,'front-subframe',     'Предна напречна греда (Субрейм)',               NULL,NULL, 5),
(9,'front-hub',          'Главина и лагер предна ос',                     NULL,NULL, 6),
(9,'front-swaybar',      'Стабилизаторна щанга предна ос',               NULL,NULL, 7),
(9,'front-swaybar-link', 'Свързваща щанга на стабилизатора (предна)',    NULL,NULL, 8);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 10. КОРМИЛНО УПРАВЛЕНИЕ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(10,'steer-rack',        'Кормилна рейка (електрическа)',                 NULL,NULL, 1),
(10,'steer-column',      'Кормилна колона',                               NULL,NULL, 2),
(10,'steer-wheel',       'Волан',                                         NULL,NULL, 3),
(10,'steer-tie-rod',     'Напречна щанга и кормилен накрайник',          NULL,NULL, 4);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 11. ЗАДНА ОС
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(11,'rear-shock',        'Заден амортисьор',                              NULL,NULL, 1),
(11,'rear-spring',       'Задна пружина',                                 NULL,NULL, 2),
(11,'rear-upper-arm',    'Горен напречен носач задна ос',                NULL,NULL, 3),
(11,'rear-lower-arm',    'Долен напречен носач задна ос',                NULL,NULL, 4),
(11,'rear-trailing-arm', 'Надлъжен носач задна ос',                      NULL,NULL, 5),
(11,'rear-subframe',     'Задна напречна греда (Субрейм)',               NULL,NULL, 6),
(11,'rear-hub',          'Главина и лагер задна ос',                     NULL,NULL, 7),
(11,'rear-swaybar',      'Стабилизаторна щанга задна ос',               NULL,NULL, 8),
(11,'rear-swaybar-link', 'Свързваща щанга на стабилизатора (задна)',    NULL,NULL, 9),
(11,'rear-diff',         'Заден диференциал',                             NULL,NULL,10);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 12. СПИРАЧНА СИСТЕМА
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(12,'brake-front',       'Предни спирачки — диск, апарат, накладки',    NULL,NULL, 1),
(12,'brake-rear',        'Задни спирачки — диск, апарат, накладки',     NULL,NULL, 2),
(12,'brake-master-cyl',  'Главен спирачен цилиндър',                    NULL,NULL, 3),
(12,'brake-servo',       'Вакуумен усилвател на спирачките',             NULL,NULL, 4),
(12,'brake-lines',       'Спирачни тръби и маркучи',                    NULL,NULL, 5),
(12,'brake-abs',         'ABS помпа и хидравличен блок',                NULL,NULL, 6),
(12,'brake-epb',         'Електронна ръчна спирачка (EPB)',              NULL,NULL, 7),
(12,'brake-pedal',       'Педал на спирачката',                         NULL,NULL, 8);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 13. КАРОСЕРИЯ
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(13,'body-front-bumper', 'Предна броня',                                  NULL,NULL, 1),
(13,'body-rear-bumper',  'Задна броня',                                   NULL,NULL, 2),
(13,'body-hood',         'Преден капак (Качулка)',                        NULL,NULL, 3),
(13,'body-trunk',        'Заден капак (Багажник)',                        NULL,NULL, 4),
(13,'body-door-front',   'Предна врата',                                  NULL,NULL, 5),
(13,'body-door-rear',    'Задна врата',                                   NULL,NULL, 6),
(13,'body-fender',       'Калник',                                        NULL,NULL, 7),
(13,'body-roof',         'Покрив',                                        NULL,NULL, 8),
(13,'body-mirrors',      'Странични огледала',                           NULL,NULL, 9),
(13,'body-lights-front', 'Предни светлини / Фарове',                    NULL,NULL,10),
(13,'body-lights-rear',  'Задни светлини / Стопове',                    NULL,NULL,11),
(13,'body-windshield',   'Предно стъкло и чистачки',                    NULL,NULL,12),
(13,'body-seals',        'Уплътнения на вратите и прозорците',          NULL,NULL,13);

-- ═══════════════════════════════════════════════════════════════
--  ПОДГРУПИ — 14. ИНТЕРИОР И ЕКСТЕРИОР
-- ═══════════════════════════════════════════════════════════════
INSERT INTO component_groups (group_id,code,name_bg,diagram_path,realoem_ref,sort_order) VALUES
(14,'trim-dashboard',    'Табло и арматурен панел',                      NULL,NULL, 1),
(14,'trim-seats',        'Седалки',                                       NULL,NULL, 2),
(14,'trim-console',      'Централна конзола',                             NULL,NULL, 3),
(14,'trim-door-panels',  'Тапицерия на вратите',                         NULL,NULL, 4),
(14,'trim-carpet',       'Мокет и шумоизолация',                         NULL,NULL, 5),
(14,'trim-headliner',    'Тавaн (тапицерия)',                            NULL,NULL, 6),
(14,'trim-steering-col', 'Облицовка на кормилната колона',               NULL,NULL, 7),
(14,'trim-ac',           'Климатик и управление',                        NULL,NULL, 8),
(14,'trim-instruments',  'Табло с инструменти / Комбиприбор',           NULL,NULL, 9),
(14,'trim-infotainment', 'iDrive / Мултимедия / Навигация',             NULL,NULL,10),
(14,'trim-sunroof',      'Панорамен люк',                                NULL,NULL,11),
(14,'trim-seatbelts',    'Предпазни колани',                             NULL,NULL,12);

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
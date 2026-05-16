SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE parts_new LIKE parts;

INSERT INTO parts_new (id, component_group_id, car_id, diagram_number, name_bg, oe_number, qty, notes_bg)
SELECT
    ROW_NUMBER() OVER (ORDER BY car_id, id) AS id,
    component_group_id,
    car_id,
    diagram_number,
    name_bg,
    oe_number,
    qty,
    notes_bg
FROM parts;


SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE component_groups_new LIKE component_groups;

INSERT INTO component_groups_new (id, group_id, car_id, code, name_bg, diagram_path, sort_order)
SELECT
    ROW_NUMBER() OVER (ORDER BY car_id, id) AS id,
    group_id,
    car_id,
    code,
    name_bg,
    diagram_path,
    sort_order
FROM component_groups;

UPDATE parts p
JOIN component_groups old_cg ON p.component_group_id = old_cg.id
JOIN component_groups_new new_cg ON new_cg.car_id = old_cg.car_id AND new_cg.code = old_cg.code
SET p.component_group_id = new_cg.id;

DROP TABLE component_groups;

RENAME TABLE component_groups_new TO component_groups;

SET FOREIGN_KEY_CHECKS = 1;
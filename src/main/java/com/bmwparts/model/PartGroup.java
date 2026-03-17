package com.bmwparts.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "part_groups")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PartGroup {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 60)
    private String code;

    @Column(name = "name_bg", nullable = false, length = 120)
    private String nameBg;

    @Column(nullable = false, length = 10)
    private String icon;

    @Column(name = "sort_order")
    private int sortOrder;

    @OneToMany(mappedBy = "group", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OrderBy("sortOrder ASC")
    private List<ComponentGroup> componentGroups;
}

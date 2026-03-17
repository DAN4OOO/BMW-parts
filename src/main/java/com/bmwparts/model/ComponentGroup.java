package com.bmwparts.model;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "component_groups")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class ComponentGroup {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id", nullable = false)
    private PartGroup group;

    @Column(nullable = false, unique = true, length = 100)
    private String code;

    @Column(name = "name_bg", nullable = false, length = 200)
    private String nameBg;

    @Column(name = "diagram_path", length = 300)
    private String diagramPath;

    @Column(name = "description_bg", columnDefinition = "TEXT")
    private String descriptionBg;

    @Column(name = "realoem_ref", length = 60)
    private String realoemRef;

    @Column(name = "sort_order")
    private int sortOrder;

    @OneToMany(mappedBy = "componentGroup", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OrderBy("diagramNumber ASC")
    private List<Part> parts;
}
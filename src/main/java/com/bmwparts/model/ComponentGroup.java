package com.bmwparts.model;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.web.util.UriUtils;
import java.nio.charset.StandardCharsets;
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

    @Column(name = "car_id", nullable = false)
    private Long carId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "car_id", insertable = false, updatable = false)
    private Car car;

    @Column(nullable = false, unique = false, length = 100)
    private String code;

    @Column(name = "name_bg", nullable = false, length = 200)
    private String nameBg;

    @Column(name = "diagram_path", length = 300)
    private String diagramPath;

    @Column(name = "sort_order")
    private int sortOrder;

    @OneToMany(mappedBy = "componentGroup", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OrderBy("diagramNumber ASC")
    private List<Part> parts;

    @Transient
    public String getDiagramSrc() {
        if (diagramPath == null || car == null || car.getDiagramsPath() == null) return null;
        return UriUtils.encodePath(car.getDiagramsPath() + "/" + diagramPath, StandardCharsets.UTF_8);
    }
}
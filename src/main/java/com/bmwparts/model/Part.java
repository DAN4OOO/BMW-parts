package com.bmwparts.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "parts")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Part {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "component_group_id", nullable = false)
    private ComponentGroup componentGroup;

    @Column(name = "car_id", nullable = false)
    private Long carId;

    @Column(name = "diagram_number", nullable = false)
    private int diagramNumber;

    @Column(name = "name_bg", nullable = false, length = 255)
    private String nameBg;

    @Column(name = "oe_number", nullable = false, length = 60)
    private String oeNumber;

    @Column
    private int qty;

    @Column(name = "notes_bg", columnDefinition = "TEXT")
    private String notesBg;
}

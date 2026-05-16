package com.bmwparts.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "cars")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class Car {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 60)
    private String make;

    @Column(nullable = false, length = 60)
    private String model;

    @Column(length = 60)
    private String series;

    @Column(length = 60)
    private String body;

    @Column(name = "engine_code", length = 30)
    private String engineCode;

    @Column(name = "engine_desc", length = 160)
    private String engineDesc;

    @Column(length = 30)
    private String fuel;

    @Column(length = 80)
    private String gearbox;

    @Column(name = "year_start")
    private Integer yearStart;

    @Column(name = "year_end")
    private Integer yearEnd;

    @Column(name = "diagrams_path", length = 300)
    private String diagramsPath;
}
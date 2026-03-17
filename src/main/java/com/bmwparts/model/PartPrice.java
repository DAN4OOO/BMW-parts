package com.bmwparts.model;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "part_prices")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class PartPrice {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "part_id", nullable = false)
    private Part part;

    @Column(nullable = false, length = 100)
    private String brand;

    @Column(name = "price_min", nullable = false, precision = 10, scale = 2)
    private BigDecimal priceMin;

    @Column(name = "price_max", nullable = false, precision = 10, scale = 2)
    private BigDecimal priceMax;

    @Column(nullable = false, length = 5)
    private String currency;

    @Column(name = "shop_url", nullable = false, length = 600)
    private String shopUrl;

    @Column(name = "shop_name", nullable = false, length = 120)
    private String shopName;
}

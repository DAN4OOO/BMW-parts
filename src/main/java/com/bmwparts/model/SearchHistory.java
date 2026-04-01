package com.bmwparts.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "search_history", indexes = {
    @Index(name = "idx_user_vin", columnList = "user_id,vin"),
    @Index(name = "idx_searched_at", columnList = "searched_at")
})
@Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
public class SearchHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 17)
    private String vin;

    @Column(name = "searched_at")
    private LocalDateTime searchedAt;

    @PrePersist
    protected void onCreate() {
        searchedAt = LocalDateTime.now();
    }
}

package com.bmwparts.repository;

import com.bmwparts.model.UserGarage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface GarageRepository extends JpaRepository<UserGarage, Long> {
    List<UserGarage> findByUser_Id(Long userId);
    Optional<UserGarage> findByUser_IdAndVin(Long userId, String vin);
    boolean existsByUser_IdAndVin(Long userId, String vin);
    long countByUser_Id(Long userId);
}

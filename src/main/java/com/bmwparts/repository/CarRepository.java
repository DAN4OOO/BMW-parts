package com.bmwparts.repository;

import com.bmwparts.model.Car;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CarRepository extends JpaRepository<Car, Long> {

    @Query("SELECT c FROM Car c WHERE c.model = :model AND (c.yearStart IS NULL OR c.yearStart <= :year) AND (c.yearEnd IS NULL OR c.yearEnd >= :year)")
    List<Car> findByModelAndYear(@Param("model") String model, @Param("year") int year);

    @Query("SELECT c FROM Car c WHERE c.diagramsPath LIKE CONCAT('%', :pattern, '%') AND (c.yearStart IS NULL OR c.yearStart <= :year) AND (c.yearEnd IS NULL OR c.yearEnd >= :year)")
    List<Car> findByDiagramsPathPatternAndYear(@Param("pattern") String pattern, @Param("year") int year);
}

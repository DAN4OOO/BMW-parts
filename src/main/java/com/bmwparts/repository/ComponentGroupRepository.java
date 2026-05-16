package com.bmwparts.repository;

import com.bmwparts.model.ComponentGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ComponentGroupRepository extends JpaRepository<ComponentGroup, Long> {

    List<ComponentGroup> findByCarIdAndGroupCodeOrderBySortOrderAsc(Long carId, String groupCode);

    List<ComponentGroup> findByCarIdOrderBySortOrderAsc(Long carId);

    @Query("SELECT DISTINCT cg FROM ComponentGroup cg LEFT JOIN FETCH cg.parts LEFT JOIN FETCH cg.car LEFT JOIN FETCH cg.group WHERE cg.carId = :carId AND cg.code = :code")
    Optional<ComponentGroup> findByCarIdAndCodeWithParts(@Param("carId") Long carId, @Param("code") String code);
}

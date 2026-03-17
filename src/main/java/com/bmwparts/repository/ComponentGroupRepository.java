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

    List<ComponentGroup> findByGroupCodeOrderBySortOrderAsc(String groupCode);

    Optional<ComponentGroup> findByCode(String code);

    @Query("SELECT DISTINCT cg FROM ComponentGroup cg " +
            "LEFT JOIN FETCH cg.parts " +
            "WHERE cg.code = :code")
    Optional<ComponentGroup> findByCodeWithParts(@Param("code") String code);
}
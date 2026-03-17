package com.bmwparts.repository;

import com.bmwparts.model.PartGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface PartGroupRepository extends JpaRepository<PartGroup, Long> {
    List<PartGroup> findAllByOrderBySortOrderAsc();
    Optional<PartGroup> findByCode(String code);
}

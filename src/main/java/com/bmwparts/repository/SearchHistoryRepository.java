package com.bmwparts.repository;

import com.bmwparts.model.SearchHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface SearchHistoryRepository extends JpaRepository<SearchHistory, Long> {
    List<SearchHistory> findByUser_IdOrderBySearchedAtDesc(Long userId);
    long countByUser_Id(Long userId);
}

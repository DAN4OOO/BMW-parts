package com.bmwparts.service;

import com.bmwparts.model.ComponentGroup;
import com.bmwparts.model.PartGroup;
import com.bmwparts.repository.ComponentGroupRepository;
import com.bmwparts.repository.PartGroupRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CatalogService {

    private final PartGroupRepository partGroupRepo;
    private final ComponentGroupRepository componentGroupRepo;

    public List<PartGroup> getAllGroups() {
        return partGroupRepo.findAllByOrderBySortOrderAsc();
    }

    public Optional<PartGroup> getGroupByCode(String code) {
        return partGroupRepo.findByCode(code);
    }

    public List<ComponentGroup> getComponentsByGroup(String groupCode) {
        return componentGroupRepo.findByGroupCodeOrderBySortOrderAsc(groupCode);
    }

    @Transactional(readOnly = true)
    public Optional<ComponentGroup> getComponentDetail(String code) {
        Optional<ComponentGroup> result = componentGroupRepo.findByCodeWithParts(code);
        result.ifPresent(cg ->
                cg.getParts().forEach(part -> part.getPrices().size())
        );
        return result;
    }
}
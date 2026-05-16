package com.bmwparts.service;

import com.bmwparts.model.Car;
import com.bmwparts.model.ComponentGroup;
import com.bmwparts.model.PartGroup;
import com.bmwparts.repository.CarRepository;
import com.bmwparts.repository.ComponentGroupRepository;
import com.bmwparts.repository.PartGroupRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
@Slf4j
@RequiredArgsConstructor
public class CatalogService {

    private final PartGroupRepository partGroupRepo;
    private final ComponentGroupRepository componentGroupRepo;
    private final CarRepository carRepository;

    public List<PartGroup> getAllGroups() {
        return partGroupRepo.findAllByOrderBySortOrderAsc();
    }

    public Optional<PartGroup> getGroupByCode(String code) {
        return partGroupRepo.findByCode(code);
    }

    public List<ComponentGroup> getComponentsByGroup(String groupCode, Long carId) {
        long id = carId != null ? carId : 1L;
        return componentGroupRepo.findByCarIdAndGroupCodeOrderBySortOrderAsc(id, groupCode);
    }

    @Transactional(readOnly = true)
    public Optional<ComponentGroup> getComponentDetail(String code, Long carId) {
        long id = carId != null ? carId : 1L;
        return componentGroupRepo.findByCarIdAndCodeWithParts(id, code);
    }

    public List<ComponentGroup> getAllComponentsByCarId(Long carId) {
        long id = carId != null ? carId : 1L;
        return componentGroupRepo.findByCarIdOrderBySortOrderAsc(id);
    }

    public Optional<Long> findMatchingCarId(String model, Integer year) {
        if (model == null || year == null) {
            return Optional.of(1L);
        }
        List<Car> cars = carRepository.findByModelAndYear(model, year);
        if (!cars.isEmpty()) {
            log.info("Matched car id={} for model={}, year={}", cars.get(0).getId(), model, year);
            return Optional.of(cars.get(0).getId());
        }
        log.warn("No car matched model={}, year={} — using fallback car_id=1", model, year);
        return Optional.of(1L);
    }
}

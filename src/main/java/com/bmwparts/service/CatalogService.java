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
import java.util.Comparator;
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

    public Optional<Long> findMatchingCarId(String nhtsaModel, Integer year, String displacement, String fuel) {
        if (nhtsaModel == null || year == null) return Optional.empty();

        String pattern = seriesPattern(nhtsaModel);
        List<Car> candidates = carRepository.findByDiagramsPathPatternAndYear(pattern, year);

        if (candidates.isEmpty()) {
            log.warn("No cars found for series pattern={} year={}", pattern, year);
            return Optional.empty();
        }

        Car best = candidates.stream()
            .max(Comparator.comparingInt(c -> score(c, displacement, fuel)))
            .orElse(candidates.get(0));

        log.info("Matched car id={} path={} (pattern={} year={} disp={} fuel={})",
            best.getId(), best.getDiagramsPath(), pattern, year, displacement, fuel);
        return Optional.of(best.getId());
    }

    private String seriesPattern(String nhtsaModel) {
        String m = nhtsaModel.trim().toUpperCase();
        if (m.contains("X1")) return "/X1/";
        if (m.contains("X2")) return "/X2/";
        if (m.contains("X3")) return "/X3/";
        if (m.contains("X4")) return "/X4/";
        if (m.contains("X5")) return "/X5/";
        if (m.contains("X6")) return "/X6/";
        if (m.contains("X7")) return "/X7/";
        if (m.contains("Z4"))  return "/Z4/";
        if (m.contains("Z3"))  return "/Z3/";
        if (m.contains("1 SERIES") || m.contains("1-SERIES") || m.matches("1\\d{2}[A-Z].*")) return "/1-Series/";
        if (m.contains("2 SERIES") || m.contains("2-SERIES") || m.matches("2\\d{2}[A-Z].*")) return "/2-Series/";
        if (m.contains("3 SERIES") || m.contains("3-SERIES") || m.matches("3\\d{2}[A-Z].*")) return "/3-Series/";
        if (m.contains("4 SERIES") || m.contains("4-SERIES") || m.matches("4\\d{2}[A-Z].*")) return "/4-Series/";
        if (m.contains("5 SERIES") || m.contains("5-SERIES") || m.matches("5\\d{2}[A-Z].*")) return "/5-Series/";
        if (m.contains("6 SERIES") || m.contains("6-SERIES") || m.matches("6\\d{2}[A-Z].*")) return "/6-Series/";
        if (m.contains("7 SERIES") || m.contains("7-SERIES") || m.matches("7\\d{2}[A-Z].*")) return "/7-Series/";
        if (m.contains("8 SERIES") || m.contains("8-SERIES") || m.matches("8\\d{2}[A-Z].*")) return "/8-Series/";
        return nhtsaModel;
    }

    private int score(Car car, String displacement, String fuel) {
        int s = 0;
        if (displacement != null && car.getEngineDesc() != null
                && car.getEngineDesc().contains(displacement + "L")) s += 2;
        if (fuel != null && car.getFuel() != null) {
            boolean wantsDiesel = fuel.toLowerCase().contains("diesel");
            boolean isDiesel = car.getFuel().contains("Дизел");
            if (wantsDiesel == isDiesel) s += 1;
        }
        return s;
    }
}

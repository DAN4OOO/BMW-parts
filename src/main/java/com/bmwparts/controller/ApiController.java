package com.bmwparts.controller;

import com.bmwparts.dto.VehicleInfo;
import com.bmwparts.model.ComponentGroup;
import com.bmwparts.service.CatalogService;
import com.bmwparts.service.VinDecodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ApiController {

    private final VinDecodeService vinDecodeService;
    private final CatalogService catalogService;

    @GetMapping("/vin/{vin}")
    public ResponseEntity<VehicleInfo> decodeVin(@PathVariable String vin) {
        VehicleInfo info = vinDecodeService.decodeVin(vin);
        return ResponseEntity.ok(info);
    }

    @GetMapping("/vin/{vin}/diagrams")
    public ResponseEntity<?> getDiagramsByVin(@PathVariable String vin) {
        try {
            VehicleInfo info = vinDecodeService.decodeVin(vin);
            if (!info.isValid()) {
                return ResponseEntity.notFound().build();
            }
            Integer year = parseYear(info.getYear());
            String model = resolveModel(info);
            Long carId = catalogService.findMatchingCarId(model, year).orElse(1L);
            List<ComponentGroup> components = catalogService.getAllComponentsByCarId(carId);
            if (components.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(components);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                    Map.of("error", "Failed to retrieve diagrams for VIN: " + vin)
            );
        }
    }

    @GetMapping("/vin/{vin}/diagrams/{componentCode}")
    public ResponseEntity<?> getComponentDetailByVin(@PathVariable String vin,
                                                     @PathVariable String componentCode) {
        try {
            VehicleInfo info = vinDecodeService.decodeVin(vin);
            if (!info.isValid()) {
                return ResponseEntity.badRequest().body(
                        Map.of("error", "Invalid VIN: " + info.getErrorMessage())
                );
            }
            Integer year = parseYear(info.getYear());
            String model = resolveModel(info);
            Long carId = catalogService.findMatchingCarId(model, year).orElse(1L);
            var componentOpt = catalogService.getComponentDetail(componentCode, carId);
            if (componentOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(componentOpt.get());
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(
                    Map.of("error", "Failed to retrieve component detail")
            );
        }
    }

    private Integer parseYear(String yearStr) {
        try {
            return yearStr != null ? Integer.parseInt(yearStr) : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String resolveModel(VehicleInfo info) {
        String engine = info.getEngineType();
        if (engine != null && !engine.isBlank() && !"unknown".equals(engine)) {
            return engine;
        }
        return info.getModel();
    }
}

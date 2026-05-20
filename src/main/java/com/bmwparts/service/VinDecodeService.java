package com.bmwparts.service;

import com.bmwparts.dto.NhtsaResponse;
import com.bmwparts.dto.VehicleInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.Map;

@Service @Slf4j @RequiredArgsConstructor
public class VinDecodeService {

    @Value("${nhtsa.api.base-url}") private String nhtsaBaseUrl;
    private final RestTemplate restTemplate;

    @Cacheable(value = "vinCache", key = "#vin.trim().toUpperCase()")
    public VehicleInfo decodeVin(String vin) {
        if (vin == null || vin.trim().length() != 17) {
            return VehicleInfo.builder().vin(vin).valid(false)
                    .errorMessage("VIN трябва да е точно 17 символа.").build();
        }

        String cleanVin = vin.trim().toUpperCase();


        if (!isValidVinCharacters(cleanVin)) {
            return VehicleInfo.builder().vin(cleanVin).valid(false)
                    .errorMessage("VIN съдържа невалидни символи. Позволени са A-H,J-N,P,R-Z,0-9.").build();
        }

        String url = nhtsaBaseUrl + cleanVin + "?format=json";
        try {
            NhtsaResponse response = restTemplate.getForObject(url, NhtsaResponse.class);
            if (response == null || response.getResults() == null) {
                return VehicleInfo.builder().vin(cleanVin).valid(false)
                        .errorMessage("Няма отговор от NHTSA API.").build();
            }
            Map<String, String> f = new HashMap<>();
            for (NhtsaResponse.NhtsaResult r : response.getResults()) {
                if (r.getValue() != null && !r.getValue().isBlank()
                        && !"Not Applicable".equalsIgnoreCase(r.getValue())
                        && !"0".equals(r.getValue())) {
                    f.put(r.getVariable(), r.getValue());
                }
            }
            String make = f.getOrDefault("Make", "");
            boolean isBmw = "BMW".equalsIgnoreCase(make);
            
            VehicleInfo.VehicleInfoBuilder builder = VehicleInfo.builder()
                    .vin(cleanVin)
                    .make(make)
                    .model(f.getOrDefault("Model", ""))
                    .year(f.getOrDefault("Model Year", ""))
                    .series(f.getOrDefault("Series", ""))
                    .trim(f.getOrDefault("Trim", ""))
                    .bodyClass(f.getOrDefault("Body Class", ""))
                    .driveType(f.getOrDefault("Drive Type", ""))
                    .engineDisplacement(f.getOrDefault("Displacement (L)", ""))
                    .fuelType(f.getOrDefault("Fuel Type - Primary", ""))
                    .transmissionStyle(f.getOrDefault("Transmission Style", ""))
                    .numberOfCylinders(f.getOrDefault("Engine Number of Cylinders", ""))
                    .plant(f.getOrDefault("Plant Country", ""))
                    .valid(isBmw)
                    .errorMessage(isBmw ? null : "Този VIN не е BMW. Марка: " + make);

            if (isBmw) {
                String nhtsaModel  = f.getOrDefault("Model", "");
                String nhtsaSeries = f.getOrDefault("Series", "");
                String yearStr     = f.getOrDefault("Model Year", "");
                String model       = extractModel(nhtsaModel, nhtsaSeries);
                builder.model(model).year(yearStr);
                log.info("Extracted vehicle info for VIN {}: model={}, year={}", cleanVin, model, yearStr);
            }

            return builder.build();
        } catch (Exception e) {
            log.error("NHTSA error for {}: {}", cleanVin, e.getMessage());
            return VehicleInfo.builder().vin(cleanVin).valid(false)
                    .errorMessage("Грешка при свързване с NHTSA. Опитайте отново.").build();
        }
    }

    private boolean isValidVinCharacters(String vin) {
        // VIN should only contain A-H,J-N,P,R-Z,0-9 (no Q)
        return vin.matches("[A-HJ-NPR-Z0-9]{17}");
    }

    private String extractModel(String model, String series) {
        // Extract clean model name from NHTSA data
        String combined = (model + " " + series).toUpperCase();
        
        if (combined.contains("3 SERIES")) return "3 Series";
        if (combined.contains("5 SERIES")) return "5 Series";
        if (combined.contains("X3")) return "X3";
        if (combined.contains("X5")) return "X5";
        if (combined.contains("X1")) return "X1";
        if (combined.contains("X2")) return "X2";
        if (combined.contains("X4")) return "X4";
        if (combined.contains("X6")) return "X6";
        if (combined.contains("X7")) return "X7";
        if (combined.contains("Z4")) return "Z4";
        if (combined.contains("Z3")) return "Z3";
        
        // Fallback - try to extract from model field
        if (model.toUpperCase().contains("SERIES")) {
            return model.substring(0, model.indexOf("SERIES") + 6).trim();
        }
        
        return model.trim();
    }

}

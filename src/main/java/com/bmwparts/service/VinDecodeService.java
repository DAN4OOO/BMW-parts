package com.bmwparts.service;

import com.bmwparts.dto.NhtsaResponse;
import com.bmwparts.dto.VehicleInfo;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.Map;

@Service @Slf4j @RequiredArgsConstructor
public class VinDecodeService {

    @Value("${nhtsa.api.base-url}") private String nhtsaBaseUrl;
    private final RestTemplate restTemplate;

    public VehicleInfo decodeVin(String vin) {
        if (vin == null || vin.trim().length() != 17) {
            return VehicleInfo.builder().vin(vin).valid(false)
                    .errorMessage("VIN трябва да е точно 17 символа.").build();
        }
        String cleanVin = vin.trim().toUpperCase();
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
            return VehicleInfo.builder()
                    .vin(cleanVin).make(make)
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
                    .errorMessage(isBmw ? null : "Този VIN не е BMW. Марка: " + make)
                    .build();
        } catch (Exception e) {
            log.error("NHTSA error for {}: {}", cleanVin, e.getMessage());
            return VehicleInfo.builder().vin(cleanVin).valid(false)
                    .errorMessage("Грешка при свързване с NHTSA. Опитайте отново.").build();
        }
    }
}

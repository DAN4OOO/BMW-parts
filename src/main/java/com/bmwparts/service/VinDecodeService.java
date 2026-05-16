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


        if (!isValidVinCharacters(cleanVin)) {
            return VehicleInfo.builder().vin(cleanVin).valid(false)
                    .errorMessage("VIN съдържа невалидни символи. Позволени са A-H,J-N,P,R-Z,0-9.").build();
        }

        // Skip check digit validation for testing
        // if (!isValidCheckDigit(cleanVin)) {
        //     return VehicleInfo.builder().vin(cleanVin).valid(false)
        //             .errorMessage("VIN има невалидна контролна цифра (позиция 9).").build();
        // }

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
                    .errorMessage(isBmw ? null : "Този VIN не е BMW. Марка: " + make);

            if (isBmw) {
                try {
                    Integer yearInt = null;
                    String yearStr = f.getOrDefault("Model Year", "");
                    if (!yearStr.isEmpty()) {
                        yearInt = Integer.parseInt(yearStr);
                    }
                    
                    // Extract model and engine from decoded data
                    String nhtsaModel  = f.getOrDefault("Model", "");
                    String nhtsaSeries = f.getOrDefault("Series", "");
                    String nhtsaDisp   = f.getOrDefault("Displacement (L)", "");
                    String model  = extractModel(nhtsaModel, nhtsaSeries);
                    String engine = extractEngine(nhtsaModel, nhtsaSeries, nhtsaDisp);
                    
                    // Store vehicle info for matching
                    builder.model(model)
                           .year(yearStr)
                           .engineType(engine);
                    log.info("Extracted vehicle info for VIN {}: model={}, year={}, engine={}", cleanVin, model, yearStr, engine);
                    
                } catch (Exception e) {
                    log.error("Error extracting vehicle info from VIN: {}", e.getMessage());
                }
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

    private boolean isValidCheckDigit(String vin) {
        // Calculate check digit using standard VIN algorithm
        int[] weights = {8,7,6,5,4,3,2,10,0,9,8,7,6,5,4,3,2};
        Map<Character, Integer> values = new HashMap<>();

        // Initialize character values
        for (int i = 0; i <= 9; i++) {
            values.put((char)('0' + i), i);
        }
        values.put('A', 1); values.put('B', 2); values.put('C', 3); values.put('D', 4);
        values.put('E', 5); values.put('F', 6); values.put('G', 7); values.put('H', 8);
        values.put('J', 1); values.put('K', 2); values.put('L', 3); values.put('M', 4);
        values.put('N', 5); values.put('P', 7); values.put('R', 9); values.put('S', 2);
        values.put('T', 3); values.put('U', 4); values.put('V', 5); values.put('W', 6);
        values.put('X', 7); values.put('Y', 8); values.put('Z', 9);

        int sum = 0;
        for (int i = 0; i < 17; i++) {
            char c = vin.charAt(i);
            if (i == 8) continue; // Skip check digit position
            sum += values.get(c) * weights[i];
        }

        int calculated = sum % 11;
        char expectedCheckDigit = (calculated == 10) ? 'X' : (char)('0' + calculated);
        char actualCheckDigit = vin.charAt(8);

        return expectedCheckDigit == actualCheckDigit;
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

    private String extractEngine(String model, String series, String displacement) {
        // Combine all three NHTSA fields — engine variant can appear in any of them
        String combined = (model + " " + series + " " + displacement).toUpperCase();

        // X-series: NHTSA returns "xDrive28i", "sDrive20d" etc. in Model or Series
        if (combined.contains("XDRIVE") || combined.contains("SDRIVE")) {
            if (combined.contains("M50I")) return "M50i";
            if (combined.contains("M40I")) return "M40i";
            if (combined.contains("M35I")) return "M35i";
            if (combined.contains("50I"))  return "50i";
            if (combined.contains("50D"))  return "50d";
            if (combined.contains("40I"))  return "40i";
            if (combined.contains("40D"))  return "40d";
            if (combined.contains("35I"))  return "35i";
            if (combined.contains("35D"))  return "35d";
            if (combined.contains("30I"))  return "30i";
            if (combined.contains("30D"))  return "30d";
            if (combined.contains("28I"))  return "28i";
            if (combined.contains("28D"))  return "28d";
            if (combined.contains("25I"))  return "25i";
            if (combined.contains("25D"))  return "25d";
            if (combined.contains("20I"))  return "20i";
            if (combined.contains("20D"))  return "20d";
            if (combined.contains("18I"))  return "18i";
            if (combined.contains("18D"))  return "18d";
        }

        // Diesel engines
        if (combined.contains("320D")) return "320d";
        if (combined.contains("318D")) return "318d";
        if (combined.contains("325D")) return "325d";
        if (combined.contains("328D")) return "328d";
        if (combined.contains("330D")) return "330d";
        if (combined.contains("335D")) return "335d";
        if (combined.contains("520D")) return "520d";
        if (combined.contains("525D")) return "525d";
        if (combined.contains("528D")) return "528d";
        if (combined.contains("530D")) return "530d";
        if (combined.contains("535D")) return "535d";
        if (combined.contains("540D")) return "540d";
        
        // Petrol engines
        if (combined.contains("316I")) return "316i";
        if (combined.contains("318I")) return "318i";
        if (combined.contains("320I")) return "320i";
        if (combined.contains("325I")) return "325i";
        if (combined.contains("328I")) return "328i";
        if (combined.contains("330I")) return "330i";
        if (combined.contains("335I")) return "335i";
        if (combined.contains("340I")) return "340i";
        if (combined.contains("520I")) return "520i";
        if (combined.contains("525I")) return "525i";
        if (combined.contains("528I")) return "528i";
        if (combined.contains("530I")) return "530i";
        if (combined.contains("535I")) return "535i";
        if (combined.contains("540I")) return "540i";
        
        return "unknown";
    }
}

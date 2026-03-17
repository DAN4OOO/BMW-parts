package com.bmwparts.controller;

import com.bmwparts.dto.VehicleInfo;
import com.bmwparts.service.VinDecodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ApiController {

    private final VinDecodeService vinDecodeService;

    @GetMapping("/vin/{vin}")
    public ResponseEntity<VehicleInfo> decodeVin(@PathVariable String vin) {
        VehicleInfo info = vinDecodeService.decodeVin(vin);
        return ResponseEntity.ok(info);
    }
}

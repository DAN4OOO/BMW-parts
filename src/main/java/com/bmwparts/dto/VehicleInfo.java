package com.bmwparts.dto;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class VehicleInfo {
    private String vin;
    private String make;
    private String model;
    private String year;
    private String series;
    private String trim;
    private String bodyClass;
    private String driveType;
    private String engineDisplacement;
    private String fuelType;
    private String transmissionStyle;
    private String numberOfCylinders;
    private String plant;
    private String errorCode;
    private String errorMessage;
    private boolean valid;
}

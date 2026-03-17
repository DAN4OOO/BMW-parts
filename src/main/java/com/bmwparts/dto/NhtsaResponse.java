package com.bmwparts.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class NhtsaResponse {
    @JsonProperty("Results") private List<NhtsaResult> results;
    @JsonProperty("Count")   private int count;
    @JsonProperty("Message") private String message;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class NhtsaResult {
        @JsonProperty("Variable")   private String variable;
        @JsonProperty("Value")      private String value;
        @JsonProperty("VariableId") private int variableId;
    }
}

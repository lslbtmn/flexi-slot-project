package com.flexislot.dto.business;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BusinessRequest {

    @NotBlank(message = "Business name is required")
    private String name;

    @NotBlank(message = "Email is required")
    @Email
    private String email;

    private String phone;
    private String location;
    private String serviceType;
    /**
     * JSON string representing operating hours (stored as LONGTEXT).
     */
    private String operatingHours;
}

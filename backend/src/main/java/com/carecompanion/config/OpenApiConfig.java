package com.carecompanion.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI careCompanionOpenApi() {
        return new OpenAPI().info(new Info()
                .title("Care Companion API")
                .version("1.0.0")
                .description("Smart Healthcare Support System for elders")
                .contact(new Contact().name("Care Companion Team")));
    }
}

package com.bmwparts;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class BmwPartsApplication {
    public static void main(String[] args) {
        SpringApplication.run(BmwPartsApplication.class, args);
    }
}

package com.example.baratico.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/login")
public class Login {

    record Person(String User, String Password){};

    @PostMapping
    public Person login(Person person){
        return person;
    }
}

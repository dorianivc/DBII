package com.example.baratico.controller;

import com.example.baratico.service.DAO;
import com.example.baratico.service.records;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@RequestMapping("/api/usuarios")
public class ControllerUsuario {

    DAO dao = new DAO();

    @PostMapping("/login")
    public records.Usuario login(@RequestBody records.Usuario person){
        return dao.login(person);
    }

    @PostMapping
    public int POSTUsuario(@RequestBody records.Usuario usuario){
        return dao.POSTUsuario(usuario);
    }

    @GetMapping
    public ArrayList<records.Usuario> GETUsuarios(){
        return dao.GETUsuarios();
    }

    @GetMapping("/{id}")
    public records.Usuario GETUsuario(@PathVariable("id") String id){
        return dao.GETUsuario(new records.Usuario(id, "", "", ""));
    }

    @PutMapping
    public records.Usuario PUTUsuario(@RequestBody records.Usuario usuario){
        return dao.PUTUsuarios(usuario);
    }


    @DeleteMapping("/{id}")
    public boolean DELETEUsuario(@PathVariable("id") String id){
        return dao.DELETEUsuario(new records.Usuario(id, "", "", ""));
    }



}

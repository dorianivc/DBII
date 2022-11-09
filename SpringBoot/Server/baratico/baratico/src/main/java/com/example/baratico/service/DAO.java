package com.example.baratico.service;


import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import java.sql.*;
import java.util.ArrayList;

public class DAO {
    final String URL = "jdbc:oracle:thin:@localhost:1521:xe";
    final String USER = "system";
    final String PASSWORD = "system";

    Connection connection;

    //logger object for saving logs
    private static final Logger logger = LogManager.getLogger();

    public void connect(){
        try {
            connection= DriverManager.getConnection(URL,USER,PASSWORD);
            if(connection!=null){
                logger.debug("Database Connection Successful");
                logger.info("Entering application.");
            }
        }catch (SQLException ex){
            logger.error("Exception in connection: "+ ex.toString());

        }
    }

    //closing the connection with database
    public void closeConnection(){
        try {
            if(connection!=null) {
                connection.close();
            }
        }catch (Exception e){
            logger.error("Exception in connection: "+ e.toString());

        }
    }


    public boolean POSTUsuario(records.Usuario usuario){
        connect();
        //sql statement for inserting record
        //delete, update, insert
        String sql = "INSERT INTO usuarios (USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (?, ?,?,?)";
        try {
            PreparedStatement statement = connection.prepareStatement(sql);
            //setting parameter values
            statement.setString(1, usuario.USUARIOSID());
            statement.setString(2, usuario.NOMBREUSUARIO());
            statement.setString(3, usuario.CONTRASENIA());
            statement.setString(4, usuario.ROL());
            //executing query which will return an integer value
            int rowsInserted = statement.executeUpdate();
            //if rowInserted is greater then 0 mean rows are inserted
            if (rowsInserted > 0) {
                logger.debug("A new user was inserted successfully!");
                return true;
            }
        }catch (Exception e){
            logger.error("Exception in connection: "+ e.toString());
            return false;
        }

        closeConnection();
        return false;
    }

    public ArrayList<records.Usuario> GETUsuarios(){
        connect();
        //sql statement for inserting record
        String sql = "select * from usuarios";
        //Creating a collection form employee list for storing all employee record
        ArrayList<records.Usuario> employeeList=new ArrayList<records.Usuario>();
        try {
            //creating and executing our statement
            Statement statement = connection.createStatement();
            ResultSet result = statement.executeQuery(sql);
            //iterating over the rows in the result
            while (result.next()) {
                //storing single result in employee object
                records.Usuario employee=new records.Usuario(result.getString(1), result.getString(2), result.getString(3), result.getString(4));
                //adding employee in employee list
                employeeList.add(employee);
            }
            //caalling function to display all record
            return employeeList;
        }catch (Exception e){
            logger.error("Exception in connection: "+ e.toString());
        }
        closeConnection();
        return employeeList;
    }
    public records.Usuario GETUsuario(records.Usuario usuario){
        ArrayList<records.Usuario> result = GETUsuarios();
        //filtra el primer usuario con x ID (FP)
        return result.stream().filter(x -> x.USUARIOSID().equals(usuario.USUARIOSID()) ).findFirst().orElse(null);
    }

    public boolean PUTUsuarios(records.Usuario usuario){
        connect();
        //sql statement for inserting record
        String sql = "update usuarios set NOMBREUSUARIO =?, CONTRASENIA=?, ROL=? where USUARIOSID=?";
        //getting input from user

        try {
            //creating and executing our statement
            PreparedStatement statement = connection.prepareStatement(sql);
            //setting parameter values
            statement.setString(1, usuario.NOMBREUSUARIO());
            statement.setString(2, usuario.CONTRASENIA());
            statement.setString(3, usuario.ROL());
            statement.setString(4, usuario.USUARIOSID());

            int rowsUpdated = statement.executeUpdate();
            //if rowInserted is greater then 0 mean rows are inserted
            if (rowsUpdated > 0) {
                logger.debug("An existing user was updated successfully!");
                return true;
            }
        }catch (Exception e){
            logger.error("Exception in connection: "+ e.toString());
            return false;

        }
        closeConnection();
        return false;
    }

    public boolean DELETEUsuario(records.Usuario usuario){
        connect();
        //sql statement for inserting record
        String sql = "DELETE FROM  usuarios WHERE USUARIOSID=?";

        try {
            //creating and executing our statement
            PreparedStatement statement = connection.prepareStatement(sql);
            //setting parameter values
            statement.setString(1, usuario.USUARIOSID());

            int rowsDeleted = statement.executeUpdate();
            //if rowInserted is greater then 0 mean rows are inserted
            if (rowsDeleted > 0) {
                logger.debug("Employee was deleted successfully!");
                return true;
            }else {
                logger.debug("Employee not found");
                return false;
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        closeConnection();
        return false;
    }


    public boolean login(records.Usuario usuario){
        try{
            return GETUsuario(usuario).CONTRASENIA().equals(usuario.CONTRASENIA());

        }catch (NullPointerException e){
            System.out.println(e);
            return false;
        }
    }

}


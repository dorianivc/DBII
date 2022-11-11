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



    public int POSTUsuario(records.Usuario usuario){
        connect();
        //sql statement for inserting record
        //delete, update, insert
        //(NOMB in varchar, CONTRA in varchar, Rl in number, idUsuario out number)
        String command = "{call SYSTEM.proc_insert_usuarios(?,?,?,?)}";
        int result = -1;
        try {
            CallableStatement cstmt = connection.prepareCall(command);

            cstmt.setString(1, usuario.NOMBREUSUARIO());     //orderId integer value to be set as input parameter
            cstmt.setString(2, usuario.CONTRASENIA());     //orderId integer value to be set as input parameter
            cstmt.setInt(3, Integer.parseInt(usuario.ROL()));     //orderId integer value to be set as input parameter
            cstmt.registerOutParameter(4, Types.INTEGER);
            cstmt.execute();
            result = cstmt.getInt(4);
            cstmt.close();

            closeConnection();
            if (result != -1) {
                logger.debug("A new user was inserted successfully!");
                return result;
            }else{
                logger.error("Exception in connection: Agregar usuario");
                return result;
            }
        }catch (Exception e){
            logger.error("Exception in connection: "+ e.toString());
            return result;
        }

    }

    public ArrayList<records.Usuario> GETUsuarios(){
        connect();
        //sql statement for inserting record
        String sql = "select * from rep_usuarios";
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
        return result.stream()
                .filter(x -> x.USUARIOSID().equals(usuario.USUARIOSID()) )
                .findFirst()
                .orElse( new records.Usuario("", "", "", ""));
    }

    public records.Usuario PUTUsuarios(records.Usuario usuario){
        connect();
        //proc_update_usuarios(idu in number ,nombre in varchar, contra in varchar, rl in number, response out number)
        String command = "{call SYSTEM.proc_update_usuarios(?,?,?,?,?)}";
        int result;

        try {
            CallableStatement cstmt = connection.prepareCall(command);

            cstmt.setInt(1, Integer.parseInt(usuario.USUARIOSID()));     //orderId integer value to be set as input parameter
            cstmt.setString(2, usuario.NOMBREUSUARIO());     //orderId integer value to be set as input parameter
            cstmt.setString(3, usuario.CONTRASENIA());     //orderId integer value to be set as input parameter
            cstmt.setInt(4, Integer.parseInt(usuario.ROL()));     //orderId integer value to be set as input parameter
            cstmt.registerOutParameter(5, Types.INTEGER);
            cstmt.execute();
            result = cstmt.getInt(5);
            cstmt.close();

            closeConnection();
            return this.GETUsuario(usuario);
        }catch (Exception e){
            logger.error("Exception in connection: "+ e.toString());
            return new records.Usuario("-1","","","");

        }
    }

    public boolean DELETEUsuario(records.Usuario usuario){
        connect();
        //sql statement for inserting record
        //proc_delete_usuarios(idu in number, response out number)
        String command = "{call SYSTEM.proc_delete_usuarios(?,?)}";
        int result;

        try {
            CallableStatement cstmt = connection.prepareCall(command);

            cstmt.setInt(1, Integer.parseInt(usuario.USUARIOSID()));     //orderId integer value to be set as input parameter
            cstmt.registerOutParameter(2, Types.INTEGER);
            cstmt.execute();

            result = cstmt.getInt(2);
            cstmt.close();

            closeConnection();
            return result == 1;
        }catch (Exception e){
            logger.error("Exception in connection: "+ e.toString());
            return false;

        }
    }


    public records.Usuario login(records.Usuario usuario){
        //usuario in varchar, passwrd in varchar, response out number
        connect();
        try{
            String command = "{call SYSTEM.proc_login(?,?,?)}";
            int result = -1;

            CallableStatement cstmt = connection.prepareCall(command);

            cstmt.setString(1, usuario.NOMBREUSUARIO());     //orderId integer value to be set as input parameter
            cstmt.setString(2, usuario.CONTRASENIA());     //orderId integer value to be set as input parameter
            cstmt.registerOutParameter(3, Types.INTEGER);
            cstmt.execute();
            result = cstmt.getInt(3);
            cstmt.close();

            closeConnection();
            if (result != -1) {
                logger.debug("user n pwd correct");
                return this.GETUsuario(new records.Usuario(String.valueOf(result), "", "",""));
            }else{
                logger.error("Exception in connection: no se encontró");
                return new records.Usuario("-1", "", "", "" );
            }


        }catch (NullPointerException e){
            System.out.println(e);
            return new records.Usuario("-1", "", "", "" );
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

}


/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.bd2una.elbaratico.Presentacion.Login;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * 
 */
public class DBconnection {
    
   public DBconnection(){
       System.out.println("Starting DB Connection");
   } 
   
   public Boolean LogIn(String user, String password){
       try{  
//step1 load the driver class  
Class.forName("oracle.jdbc.driver.OracleDriver");  
  
//step3 create the statement object
            try (//step2 create  the connection object
                    Connection con = DriverManager.getConnection(  
                            "jdbc:oracle:thin:@localhost:1521:xe",user,password)) {
                if (con==null){
                    System.out.println("No conectado");
                    return false;
                }else{
                    System.out.println("Conectado");
                    return true;
                }
            } catch (SQLException ex) {  
                System.out.println(ex.getMessage());
                return false;
         }  
       }catch(ClassNotFoundException e){
           System.out.println(e.getMessage());
       }    
       return false;
   }
     

}

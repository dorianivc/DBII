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
   
   private DBconnection(){
       System.out.println("Starting DB Connection");
   } 
   
   private String username;
   private String password;
   
   
   private static DBconnection instance = null;
   
   public static DBconnection getInstance () {
       if(instance == null){
           instance = new DBconnection();
       }
       return instance;
   }

   public Boolean ExecuteQuery(String query){
       try(Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe",username, password);
         Statement stmt = conn.createStatement();
      ) {		      
         // Execute a query
         System.out.println("Running query");          
         String sql = query;
         stmt.executeUpdate(sql);
         System.out.println("Query ran successfuly");   	  
      } catch (SQLException e) {
         System.out.println(e.getMessage());
         return false;
      } 
      return true;
   }
   
   public Boolean LogIn(String user, String pass){
       try{  
//step1 load the driver class  
Class.forName("oracle.jdbc.driver.OracleDriver");  
  
//step3 create the statement object
            try (//step2 create  the connection object
                    Connection con = DriverManager.getConnection(  
                            "jdbc:oracle:thin:@localhost:1521:xe",user,pass)) {
                if (con==null){
                    System.out.println("No conectado");
                    return false;
                }else{
                    System.out.println("Conectado");
                    this.username = user;
                    this.password = pass;
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

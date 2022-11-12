

-- Procedures, Functions & view de Tabla Usuarios
-- GETusuario
create or replace view rep_usuarios as
select * from usuarios;


-- PUTusuatio
create or replace procedure system.proc_insert_usuarios(NOMB in varchar, CONTRA in varchar, Rl in number, idUsuario out number) as
begin
  INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, NOMB, CONTRA, Rl);
  idUsuario := sec_usuarios.currval;
  exception
  when others then
    idUsuario := -1;
end proc_insert_usuarios;
/



--Login
create or replace procedure system.proc_login(usuario in varchar, passwrd in varchar, response out number ) AUTHID DEFINER as
begin
    select USUARIOSID into response
    from rep_usuarios 
    where NombreUsuario = usuario and Contrasenia = passwrd;  
exception
  when others then
    response := -1;
end proc_login;


-- PUTusuario
create or replace procedure system.proc_update_usuarios(idu in number ,nombre in varchar, contra in varchar, rl in number, response out number) as
begin
    update usuarios set NOMBREUSUARIO = nombre, CONTRASENIA=contra, ROL= rl where USUARIOSID = idu;
    response := 1;
exception
  when others then
    response := -1;
end proc_update_usuarios;

-- DELETEusuario
create or replace procedure system.proc_delete_usuarios(idu in number, response out number) as
begin
    delete from usuarios where usuariosid = idu;
    response := 1;
exception
  when others then
    response := -1;        
end proc_delete_usuarios;





grant select on rep_usuarios to Cajero;
GRANT ALL ON proc_login TO Cajero;


grant select on rep_usuarios to GerenteArea;
GRANT ALL ON proc_login TO GerenteArea;

grant select on rep_usuarios to GerenteGeneral;
GRANT ALL ON proc_login TO GerenteGeneral;
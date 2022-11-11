alter session set "_ORACLE_SCRIPT" = true;

drop table Usuarios cascade constraints;
drop table Inventario cascade constraints;
drop table Area cascade constraints;
drop table Factura cascade constraints;
drop table Detalle cascade constraints;
drop table Producto cascade constraints;
drop table BitacoraFactura;
drop table BitacoraCajero;
drop table Bitacora;





drop trigger usuarios_trg_axr;
drop trigger Area_trg_axr;
drop trigger Factura_trg_axr;
drop trigger Detalle_trg_axr;
drop trigger Producto_trg_axr;
drop trigger Inventario_trg_axr;


-- TODOOOOOOOOOOOOOOOOOOOOOOO
drop sequence sec_usuarios;
-- Secuencias
-- Ver el último valor utilizado
-- user_sequence.currval
create sequence sec_usuarios start with 1;
-- insert into empleados(id, nombre, salario) values (sec_usuarios.nextval, 'Ana', 1500);


--Manejamos los roles como un int
create table Usuarios (
    UsuariosID number,
    NombreUsuario varchar(150),
    Contrasenia varchar(150),
    Rol number, 
    primary key (UsuariosID),
    CONSTRAINT check_role
    CHECK (Rol BETWEEN 1 and 10)
);
    --TODO: ver cantidad



create table Area (
    AreaID number,
    Nombre varchar(50) unique,
    GerenteID number unique, 
    primary key (AreaID),
    foreign key (GerenteID)
    references Usuarios (UsuariosID),
    CONSTRAINT check_area
    CHECK ( lower(Nombre) in ('abarrotes', 'cuidado personal', 'mercancias', 'frescos') )
);

--suponemos que el super tiene 3 cajas solamente
create table Factura (
    FacturaID number, 
    CajeroID number, 
    NumeroCaja number,
    Total decimal(2,0),
    Fecha TIMESTAMP,
    primary key (FacturaID),
    foreign key (CajeroID)
    references Usuarios(UsuariosID),
    CONSTRAINT check_numero_caja
    CHECK (NumeroCaja BETWEEN 1 and 3)
);
--TODO: ck cajero id debe ser de tipo cajero
--TODO: trigger que actualiza el total del la factura

create table Producto(
    EAN number,
    PLU number,
    Descripcion varchar(150),
    Precio decimal(2,0),
    AreaID number,
    primary key (EAN),
    foreign key (AreaID)
    references Area(AreaID)
);

--tabla intermedia de los productos ligados a una factura
create table Detalle(
    DetalleID number,
    ProductoID number,
    Cantidad decimal(2,0),
    Subtotal decimal(2,0),
    FacturaID number,
    primary key (DetalleID),
    foreign key (ProductoID)
    references Producto(EAN)
);



create table Inventario (
    AreaID number,
    ProductoID number,
    Cantidad decimal(2,0),
    foreign key (AreaID)
    references Area(AreaID),
    foreign key (ProductoID)
    references Producto(EAN)
);
--TODO: validar si no es un mercancia, no permite decimal

---------------------------------------------------------------------------
--Bitacoras

create Table Bitacora(
    Operacion varchar(20),
    Usuario varchar(100), 
    Fecha TIMESTAMP,
    Tabla varchar(100)
);



create Table BitacoraCajero(
  Usuario varchar(100),
  NumeroCaja number,
  NumeroFactura number, 
  MontoTotal decimal(2, 0),
  fecha TIMESTAMP
);

create Table BitacoraFactura(
    FacturaID number,
    ProductoID number,
    Cantidad decimal(2,0),
    Subtotal decimal(2,0),
    Total decimal(2,0),
    CajeroID number,
    CajaID number,
    Fecha timestamp
);



--After insert porque primero crea la factura
--luego inserta el detalle, luego calcula el total
--y luego actualiza el total en la factura
CREATE TRIGGER factura_trg_air AFTER INSERT
  ON Factura FOR EACH ROW
BEGIN

--Insert cuando hago agrego un producto a una factura
INSERT INTO BitacoraFactura(FacturaID,ProductoID,Cantidad,Subtotal,Total,CajeroID,CajaID,Fecha) SELECT F.FacturaID,
        D.ProductoID,
        D.Cantidad,
        D.Subtotal,
        F.Total,
        F.CajeroID,
        F.NumeroCaja,
        CAST(F.Fecha AS TIMESTAMP)
    from Factura F
    inner join Detalle D
        on D.FacturaID = F.FacturaID
    Where F.FacturaID = :new.FacturaID;

--Insert del cajero que ingreso el dato en la factura
INSERT INTO BitacoraCajero(Usuario,NumeroCaja,NumeroFactura,MontoTotal,fecha)
    SELECT (SELECT USER FROM dual),
        NumeroCaja,
        FacturaID,
        Total,
        CAST(Fecha AS TIMESTAMP)
    from Factura
    Where FacturaID = :new.FacturaID;

END;

---------------------------------------------------------------------------
-- Triggers Maestros


-- trigger Usuarios
CREATE TRIGGER usuarios_trg_axr AFTER INSERT OR DELETE OR UPDATE ON Usuarios FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values ('Insert', userName, sysdate, 'Usuarios');
  ELSIF DELETING THEN
    insert into Bitacora 
    values ('Delete', userName, sysdate, 'Usuarios');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values ('Update', userName, sysdate, 'Usuarios');
  END IF;
END;




-- trigger Area
CREATE TRIGGER Area_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Area FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values ('Insert', userName, sysdate, 'Area');
  ELSIF DELETING THEN
    insert into Bitacora 
    values ('Delete', userName, sysdate, 'Area');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values ('Update', userName, sysdate, 'Area');
  END IF;
END;


--trigger Factura
CREATE TRIGGER Factura_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Factura FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values ('Insert', userName, sysdate, 'Factura');
  ELSIF DELETING THEN
    insert into Bitacora 
    values ('Delete', userName, sysdate, 'Factura');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values ('Update', userName, sysdate, 'Factura');
  END IF;
END;


--trigger Detalle 
CREATE TRIGGER Detalle_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Detalle FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values ('Insert', userName, sysdate, 'Detalle');
  ELSIF DELETING THEN
    insert into Bitacora 
    values ('Delete', userName, sysdate, 'Detalle');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values ('Update', userName, sysdate, 'Detalle');
  END IF;
END;


--trigger Producto  
CREATE TRIGGER Producto_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Producto FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values ('Insert', userName, sysdate, 'Producto');
  ELSIF DELETING THEN
    insert into Bitacora 
    values ('Delete', userName, sysdate, 'Producto');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values ('Update', userName, sysdate, 'Producto');
  END IF;
END;



--trigger Inventario  
CREATE TRIGGER Inventario_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Inventario FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values ('Insert', userName, sysdate, 'Inventario');
  ELSIF DELETING THEN
    insert into Bitacora 
    values ('Delete', userName, sysdate, 'Inventario');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values ('Update', userName, sysdate, 'Inventario');
  END IF;
END;


---------------------------------------------------------------------------

--roles
-- ROL CAJERO
-- Solo pueden realizar ventas y consultar precios de productos
create role Cajero;
grant select on Producto to Cajero;
-- ROL GERENTE DE AREA
-- Pueden hacer update a los productos del area bajo su cargo
-- Pueden realizar consultas de productos
-- No pueden hacer insert ni delete
create role GerenteArea;
grant update(Descripcion) on Producto to GerenteArea;
grant update(Cantidad) on Producto to GerenteArea;
grant select on Producto to GerenteArea;
-- ROL  GERENTE GENERAL
-- CRUD sobre la tabla de productos
create role GerenteGeneral;
grant select on Producto to GerenteGeneral;
grant delete on Producto to GerenteGeneral;
grant insert on Producto to GerenteGeneral;
grant update on Producto to GerenteGeneral;
-- ROL ENCARGADO DE SISTEMAS
-- CRUD sobre la tabla de productos
-- Puede ejecutar cualquier procedimiento
-- Puede respaldar y restaurar la base de datos del PV
-- CRUD sobre tablas maestras (Usuarios, Area, Inventario)
-- Puede leer la bitacora
create role EncargadoSistemas;
grant DBA to EncargadoSistemas;

 
    
    

-- Procedures & Functions Tabla Usuarios
create or replace procedure proc_insert_usuarios(NOMB in varchar, CONTRA in varchar, Rl in number, idUsuario out number) as
begin
  INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, NOMB, CONTRA, Rl);
  idUsuario := sec_usuarios.currval;
  exception
  when others then
    idUsuario := -1;
end proc_insert_usuarios;
/


exec proc_insert_usuarios('Norman', '124', 1, nu);

select * from usuarios;


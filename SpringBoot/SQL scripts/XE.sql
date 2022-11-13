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



-- TODOOOOOOOOOOOOOOOOOOOOOOO
drop sequence sec_usuarios;
drop sequence sec_bitacora;
drop sequence sec_bitacora_cajero;
drop sequence sec_bitacora_factura;
drop sequence sec_facturas;
drop sequence sec_detalles;
drop sequence sec_area;
drop sequence sec_inventario;

DROP USER Cajero1;
DROP USER Cajero2;
DROP USER Cajero3;
DROP USER GerenteAbarrottes;
DROP USER GerenteCuidado;
DROP USER GerenteMercancias;
DROP USER GerenteFrescos;
DROP USER GerenteGeneral_1;
DROP USER GerenteGeneral_2;
DROP USER AdminSistemas;

drop role Cajero;
drop role GerenteArea;
drop role GerenteGeneral;
drop role EncargadoSistemas;






create sequence sec_bitacora start with 1;
create sequence sec_bitacora_cajero start with 1;
create sequence sec_bitacora_factura start with 1;
create sequence sec_usuarios start with 1;
create sequence sec_facturas start with 1;
create sequence sec_detalles start with 1;
create sequence sec_area start with 1;
create sequence sec_inventario start with 1;


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
    /*
    Roles
        1 ->  Gerente General
        2 ->  Gerente abarrotes
        3 ->  Gerente cuidado personal
        4 ->  Gerente mercanc�as
        5 ->  Gerente frescos
        6 ->  Gerente frescos
        7 ->  Cajero    
        10 -> admin de sistemas
    */



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
--TODO: ck cajero id debe ser de tipo cajero LISTO
--TODO: trigger que actualiza el total del la factura ????

create  table Producto(
    EAN number, --id (13 caracteres)
    PLU number, --id (5 digitos) para frescos
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
    InventarioId number,
    AreaID number,
    ProductoID number,
    Cantidad decimal(2,0),
    foreign key (AreaID)
    references Area(AreaID),
    foreign key (ProductoID)
    references Producto(EAN), 
    primary key(InventarioID)
);
--TODO: validar si no es un mercancia, no permite decimal

---------------------------------------------------------------------------
--Bitacoras



create Table Bitacora(
    BitacoraId number,
    Operacion varchar(20),
    Usuario varchar(100), 
    Fecha TIMESTAMP,
    Tabla varchar(100),
    primary key(BitacoraId)
);


create Table BitacoraCajero(
  BitacoraCajeroId number,
  Usuario varchar(100),
  NumeroCaja number,
  NumeroFactura number, 
  MontoTotal decimal(2, 0),
  fecha TIMESTAMP,
  primary key(BitacoraCajeroId)
);

create Table BitacoraFactura(
    BitacoraFacturaId number,
    FacturaID number,
    ProductoID number,
    Cantidad decimal(2,0),
    Subtotal decimal(2,0),
    Total decimal(2,0),
    CajeroID number,
    CajaID number,
    Fecha timestamp,
    primary key(BitacoraFacturaId)
);
-- Vistas
create or replace view cajero_productos as
select Descripcion, precio
from Producto;



--***************************************************************************
-- Triggers
-- Trigger productos, Solo el gerente general puede hacer insert y delete.
create or replace trigger producto_before_insert_or_delete
before insert or delete on producto
for each row
declare 
    v_rolUsuario number;
    v_nombreUsuario varchar(20);
begin
    select sys_context('USERENV', 'SESSION_USER') into v_nombreUsuario from dual;
    select Rol into v_rolUsuario from Usuarios where NombreUsuario = v_nombreUsuario;
    
    if(v_rolUsuario <> 1 or v_rolUsuario <> 10 )
        then RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente general');
    end if;
end;
/

-- Trigger productos, Gerente general y Gerente de area pueden modificar descripcion de producto.
create or replace trigger producto_before_update_descripcion
before update of Descripcion on Producto
for each row
declare 
    v_rolUsuario number;
    v_nombreUsuario varchar(20);
    v_areaProducto varchar(20);
begin
    select sys_context('USERENV', 'SESSION_USER') into v_nombreUsuario from dual;
    select Rol into v_rolUsuario from Usuarios where NombreUsuario = v_nombreUsuario;
    
    select :new.descripcion into v_areaProducto from Producto;
        
    case lower(v_areaProducto)
        when 'abarrotes' then
            if (v_rolUsuario <> 2 or v_rolUsuario <> 1 or v_rolUsuario <> 10) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
        when 'cuidado personal' then
            if (v_rolUsuario <> 3  or v_rolUsuario <> 1 or v_rolUsuario <> 10) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
        when 'mercancias' then
            if (v_rolUsuario <> 4  or v_rolUsuario <> 1 or v_rolUsuario <> 10) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
        when 'frescos' then
            if (v_rolUsuario <> 5  or v_rolUsuario <> 1 or v_rolUsuario <> 10) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
    end case;   
end;
/

-- Trigger productos, Solo el gerente general puede hacer update
create or replace trigger producto_before_update_other
before update of EAN, PLU, Precio, AreaID on Producto
for each row
declare 
    v_rolUsuario number;
    v_nombreUsuario varchar(20);
begin
    select sys_context('USERENV', 'SESSION_USER') into v_nombreUsuario from dual;
    select Rol into v_rolUsuario from Usuarios where NombreUsuario = v_nombreUsuario;
    
    if(v_rolUsuario <> 1 or v_rolUsuario <> 10)
        then RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente general');
    end if;
end;
/



-- trigger inventario, check que solo gerente de esa area pueda modificar la cantidad.
create or replace trigger inventario_before_update_cantidad
before update of Cantidad on Inventario
for each row
declare 
    v_rolUsuario number;
    v_nombreUsuario varchar(20);
    v_nombreArea varchar(20);
begin
    select sys_context('USERENV', 'SESSION_USER') into v_nombreUsuario from dual;
    select Rol into v_rolUsuario from Usuarios where NombreUsuario = v_nombreUsuario;
    
    select a.Nombre 
    into v_nombreArea 
    from Area a
    inner join Inventario i
    on a.AreaID = :new.AreaID;
    
    case lower(v_nombreArea)
        when 'abarrotes' then
            if (v_rolUsuario <> 2 or v_rolUsuario <> 10) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
        when 'cuidado personal' then
            if (v_rolUsuario <> 3 or v_rolUsuario <> 10) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
        when 'mercancias' then
            if (v_rolUsuario <> 4 or v_rolUsuario <> 10) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
        when 'frescos' then
            if (v_rolUsuario <> 5 or v_rolUsuario <> 10 ) then
                RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un gerente del area del producto indicado');
            end if;
    end case;   
end;
/



-- Trigger detalle
create or replace trigger detalle_before_insert
before insert on Detalle
for each row
declare
    v_cajeroID number;
begin
    select CajeroID into v_cajeroID from Factura where FacturaID = :new.FacturaID;
    if(v_cajeroID is null) 
    then RAISE_APPLICATION_ERROR( -20001, 'La factura no existe');
    end if;
end;
/

-- Trigger Usuarios checkea 2 Gerentes Generales como maximo
create or replace trigger usuarios_before_insert 
before insert on Usuarios
for each row
declare
    v_cantidadGG number;
begin
    if (:new.Rol = 1)
    then
        select Count(*) into v_cantidadGG from Usuarios where Rol = 1;
        if(v_cantidadGG = 2)
        then 
            RAISE_APPLICATION_ERROR( -20001, 'Solo pueden existir dos Gerentes Generales');
        end if;
    end if;
end;
/

-- Trigger Factura
create or replace trigger factura_before_insert
before insert on Factura
for each row
declare
    v_usuarioRol number;
    v_rolUsuario varchar(20);
    v_nombreUsuario varchar(20);
begin
    select Rol into v_usuarioRol from Usuarios where UsuariosID = :new.CajeroID;
    if (v_usuarioRol <> 7 or v_rolUsuario <> 10)
        then RAISE_APPLICATION_ERROR( -20001, 'El usuario insertado no es un cajero');
    end if;
    
    select sys_context('USERENV', 'SESSION_USER') into v_nombreUsuario from dual;
    select Rol into v_rolUsuario from Usuarios where NombreUsuario = v_nombreUsuario;
    
    if(v_rolUsuario <> 7 or v_rolUsuario <> 10)
        then RAISE_APPLICATION_ERROR( -20001, 'El usuario actual no es un cajero');
    end if;
end;
/
-- 
create or replace trigger area_before_insert
before insert on Area
for each row
declare
    v_rolUsuario number;
begin
    select Rol into v_rolUsuario from Usuarios where UsuariosID = :new.GerenteID;
    if (v_rolUsuario > 6 or v_rolUsuario <> 10)
    then RAISE_APPLICATION_ERROR( -20001, 'El usuario insertado no es gerente');
    end if;
end;
/
-- Procedures 
-- insertar usuario
create or replace procedure proc_insertar_usuario ( 
                            p_NombreUsuario in Usuarios.NombreUsuario%type,
                            p_Contrasenia in Usuarios.Contrasenia%type,
                            p_Rol in Usuarios.Rol%type)
is 
begin
    insert into Usuarios values (sec_usuarios.nextval, p_NombreUsuario,p_Contrasenia, p_Rol);
    commit;
end;
/


-- crud area, factura, producto, detalle e inventario

-- CRUD Area
create or replace procedure proc_insert_area (
                            p_Nombre in Area.Nombre%type,
                            p_GerenteID in Area.GerenteID%type)
is 
begin
    insert into Area values (sec_area.nextval, p_Nombre, p_GerenteID);
end;
/

create or replace view rep_Area as
select AREAID,NOMBRE,GERENTEID from Area;

create or replace procedure proc_update_area (
                            p_AreaID in Area.AreaID%type,
                            p_Nombre in Area.Nombre%type,
                            p_GerenteID in Area.GerenteID%type)
is 
begin
    update Area set Nombre = p_Nombre, GerenteID = p_GerenteID where AreaID = p_AreaID;
    commit;
end;
/

create or replace procedure proc_delete_area (p_AreaID in Area.AreaID%type)
is 
begin  
    delete from Area where AreaID = p_AreaID;
    commit;
end;
/
 
 
 -- CRUD Factura
create or replace procedure proc_insert_factura(
                            p_CajeroID in Factura.CajeroID%type,
                            p_NumeroCaja in Factura.NumeroCaja%type)
is 
begin
    insert into Factura values (sec_facturas.nextval, p_CajeroID, p_NumeroCaja, 0, sysdate);
    commit;
end;
/

create or replace view rep_Factura as
select FACTURAID,CAJEROID,NUMEROCAJA,TOTAL,FECHA  
from Factura;

create or replace procedure proc_update_Factura (
                            p_FacturaID in Factura.FacturaID%type,
                            p_CajeroID in Factura.CajeroID%type,
                            p_NumeroCaja in Factura.NumeroCaja%type,
                            p_Total in Factura.Total%type,
                            p_Fecha in Factura.Fecha%type)
is 
begin
    update Factura set CajeroID = p_CajeroID, NumeroCaja = p_NumeroCaja, Total = p_Total, Fecha = p_Fecha where FacturaID = p_FacturaID;
    commit;
end;
/

create or replace procedure proc_delete_Factura (p_FacturaID in Factura.FacturaID%type)
is 
begin  
    delete from Factura where FacturaID = p_FacturaID;
    commit;
end;
/

-- CRUD Inventario

create or replace procedure proc_insert_Inventario(
                            p_AreaID in number,
                            p_ProductoID in number,
                            p_Cantidad in Inventario.Cantidad%type)
is 
begin
    insert into Inventario values (sec_inventario.nextval, p_AreaID, p_ProductoID,p_Cantidad);
    commit;
end;
/

create or replace view rep_Inventario as
select INVENTARIOID,AREAID,PRODUCTOID,CANTIDAD from Inventario;

create or replace procedure proc_update_Inventario (
                            p_InventarioID in number,
                            p_AreaID in number,
                            p_ProductoID in number,
                            p_Cantidad in Inventario.Cantidad%type)
is 
begin
    update Inventario set AreaID = p_AreaID, ProductoID = p_ProductoID, Cantidad = p_Cantidad where InventarioID = p_InventarioID;
    commit;
end;
/

create or replace procedure proc_delete_Inventario (p_InventarioID in Inventario.InventarioID%type)
is 
begin  
    delete from Inventario where InventarioID = p_InventarioID;
    commit;
end;
/

    
    
-- CRUD Producto

create or replace procedure proc_insert_producto(
                            p_EAN in number, 
                            p_PLU in number,
                            p_Descripcion in Producto.Descripcion%type,
                            p_Precio in Producto.Precio%type,
                            p_AreaID in Producto.AreaID%type)
is 
begin
    insert into Producto values (p_EAN, p_PLU,p_Descripcion, p_Precio, p_AreaID);
    commit;
end;
/

create or replace view rep_Producto as
select EAN ,PLU ,DESCRIPCION ,PRECIO ,AREAID  from producto;

create or replace procedure proc_update_Producto (
                            p_EAN in number, 
                            p_PLU in number,
                            p_Descripcion in Producto.Descripcion%type,
                            p_Precio in Producto.Precio%type,
                            p_AreaID in Producto.AreaID%type)
is 
begin
    update Producto set PLU = p_PLU, Descripcion = p_Descripcion, Precio = p_Precio, AreaID = p_AreaID where  EAN = p_EAN;
    commit;
end;
/

create or replace procedure proc_delete_Inventario (p_EAN in number)
is 
begin  
    delete from Producto where EAN = p_EAN;
    commit;
end;
/

    
-- CRUD Detalle

create or replace procedure proc_insert_detalle(
                            p_ProductoID in Detalle.ProductoID%type,
                            p_Cantidad in Detalle.Cantidad%type,
                            p_FacturaID in Detalle.FacturaID%type)
is
    v_totalFactura decimal(2,0); -- Lo que la factura ya trae. Empieza en 0
    v_precioProducto decimal(2,0); -- Lo que cuesta cada uno de los productos
    v_productoTotal decimal(2,0); -- Precio del producto * cantidad del producto
    v_totalFinal decimal(2,0); -- ProductoTotal + totalFactura
    
    v_cantidadInventario number;
begin
    select Cantidad 
    into v_cantidadInventario 
    from Inventario 
    where ProductoID = p_ProductoID;
    
    if(v_cantidadInventario < p_cantidad)
    then RAISE_APPLICATION_ERROR( -20001, 'No hay tal cantidad en inventario');
    end if;
    
    select Total 
    into v_totalFactura 
    from Factura 
    where FacturaID = p_FacturaID; 
    
    select Precio
    into v_precioProducto
    from Producto
    where EAN = p_ProductoID;
    
    v_productoTotal := v_precioProducto * p_Cantidad;
    
    v_totalFinal := v_totalFactura + v_productoTotal;
    
    insert into Detalle values (sec_Detalles.nextval, p_ProductoID, p_Cantidad, v_productoTotal, p_FacturaID);
    update Factura f set f.Total = v_totalFinal where f.FacturaID = p_FacturaID;
end;
/

create or replace procedure proc_update_Detalle (
                            p_DetalleID in number, 
                            p_ProductoID in number,
                            p_Cantidad in decimal,
                            p_Subtotal in decimal,
                            p_FacturaID in number)
is 
begin
    update Detalle set ProductoID = p_ProductoID, Cantidad = p_Cantidad, Subtotal = p_Subtotal, FacturaID = p_FacturaID where DetalleID = p_DetalleID;
    commit;
end;
/

create or replace view rep_Detalle as
select DETALLEID ,PRODUCTOID ,CANTIDAD ,SUBTOTAL ,FACTURAID  from Detalle;


create or replace procedure proc_delete_Detalle (p_DetalleID in number)
is 
begin  
    delete from Detalle where DetalleID = p_DetalleID;
    commit;
end;
/


---------------------------------------------------------------------------

--roles
-- ROL CAJERO
-- Solo pueden realizar ventas y consultar precios de productos
create role Cajero;
grant select on Producto to Cajero;

CREATE USER Cajero1 IDENTIFIED BY Cajero;
CREATE USER Cajero2 IDENTIFIED BY Cajero;
CREATE USER Cajero3 IDENTIFIED BY Cajero;


GRANT CONNECT TO Cajero1; 
GRANT CONNECT TO Cajero2; 
GRANT CONNECT TO Cajero3; 

GRANT Cajero TO Cajero1;
GRANT Cajero TO Cajero2;
GRANT Cajero TO Cajero3;


INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'Cajero1', 'Cajero', 7);
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'Cajero2', 'Cajero', 7);
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'Cajero3', 'Cajero', 7);

-- ROL GERENTE DE AREA
-- Pueden hacer update a los productos del area bajo su cargo
-- Pueden realizar consultas de productos
-- No pueden hacer insert ni delete
create role GerenteArea;
grant update(Descripcion) on Producto to GerenteArea;
grant select on Producto to GerenteArea;


-- Gerente de Abarrotes
CREATE USER GerenteAbarrottes IDENTIFIED BY GerenteArea;
GRANT CONNECT TO GerenteAbarrottes;  
GRANT GerenteArea TO GerenteAbarrottes;
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'GerenteAbarrottes', 'GerenteArea', 2);



-- Gerente de Cuidado personal
CREATE USER GerenteCuidado IDENTIFIED BY GerenteArea;
GRANT CONNECT TO GerenteCuidado;  
GRANT GerenteArea TO GerenteCuidado;
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'GerenteCuidado', 'GerenteArea', 3);


-- Gerente de Mercancias
CREATE USER GerenteMercancias IDENTIFIED BY GerenteArea;
GRANT CONNECT TO GerenteMercancias;  
GRANT GerenteArea TO GerenteMercancias;
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'GerenteMercancias', 'GerenteArea', 4);

-- Gerente de Frescos
CREATE USER GerenteFrescos IDENTIFIED BY GerenteArea;
GRANT CONNECT TO GerenteFrescos;  
GRANT GerenteArea TO GerenteFrescos;
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'GerenteFrescos', 'GerenteArea', 5);



-- ROL  GERENTE GENERAL
-- CRUD sobre la tabla de productos
create role GerenteGeneral;
grant select on Producto to GerenteGeneral;
grant delete on Producto to GerenteGeneral;
grant insert on Producto to GerenteGeneral;
grant update on Producto to GerenteGeneral;




-- Gerente General 1
CREATE USER GerenteGeneral_1 IDENTIFIED BY GerenteGeneral;
GRANT CONNECT TO GerenteGeneral_1;  
GRANT GerenteGeneral TO GerenteGeneral_1;
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'GerenteGeneral_1', 'GerenteGeneral', 1);
-- Gerente General 2
CREATE USER GerenteGeneral_2 IDENTIFIED BY GerenteGeneral;
GRANT CONNECT TO GerenteGeneral_2;  
GRANT GerenteGeneral TO GerenteGeneral_2;
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'GerenteGeneral_2', 'GerenteGeneral', 1);




-- ROL ENCARGADO DE SISTEMAS
-- CRUD sobre la tabla de productos
-- Puede ejecutar cualquier procedimiento
-- Puede respaldar y restaurar la base de datos del PV
-- CRUD sobre tablas maestras (Usuarios, Area, Inventario)
-- Puede leer la bitacora
create role EncargadoSistemas;
grant DBA to EncargadoSistemas;

-- Encargado de sistemas
CREATE USER AdminSistemas IDENTIFIED BY AdminSistemas;
GRANT CONNECT TO AdminSistemas;  
GRANT EncargadoSistemas TO AdminSistemas;
INSERT INTO usuarios(USUARIOSID, NOMBREUSUARIO, CONTRASENIA, ROL) VALUES (sec_usuarios.nextval, 'AdminSistemas', 'AdminSistemas', 10);


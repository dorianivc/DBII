--drop trigger usuarios_trg_axr;
--drop trigger Area_trg_axr;
--drop trigger Factura_trg_axr;
--drop trigger Detalle_trg_axr;
--drop trigger Producto_trg_axr;
--drop trigger Inventario_trg_axr;
--drop trigger factura_trg_air;




--After insert porque primero crea la factura
--luego inserta el detalle, luego calcula el total
--y luego actualiza el total en la factura
CREATE or replace TRIGGER factura_trg_air AFTER INSERT
  ON Factura FOR EACH ROW
BEGIN

--Insert cuando hago agrego un producto a una factura
INSERT INTO BitacoraFactura (FacturaID,ProductoID,Cantidad,Subtotal,Total,CajeroID,CajaID,Fecha) SELECT 
        F.FacturaID,
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

-- Triggers Maestros


-- trigger Usuarios
CREATE or replace TRIGGER usuarios_trg_axr AFTER INSERT OR DELETE OR UPDATE  ON Usuarios FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval ,'Insert', userName, sysdate, 'Usuarios');
  ELSIF DELETING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval, 'Delete', userName, sysdate, 'Usuarios');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Update', userName, sysdate, 'Usuarios');
  END IF;
END;


-- trigger Area
CREATE or replace TRIGGER Area_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Area FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Insert', userName, sysdate, 'Area');
  ELSIF DELETING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Delete', userName, sysdate, 'Area');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Update', userName, sysdate, 'Area');
  END IF;
END;


--trigger Factura
CREATE or replace TRIGGER Factura_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Factura FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Insert', userName, sysdate, 'Factura');
  ELSIF DELETING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Delete', userName, sysdate, 'Factura');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Update', userName, sysdate, 'Factura');
  END IF;
END;


--trigger Detalle 
CREATE or replace TRIGGER Detalle_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Detalle FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Insert', userName, sysdate, 'Detalle');
  ELSIF DELETING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Delete', userName, sysdate, 'Detalle');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Update', userName, sysdate, 'Detalle');
  END IF;
END;


--trigger Producto  
CREATE or replace TRIGGER Producto_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Producto FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Insert', userName, sysdate, 'Producto');
  ELSIF DELETING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Delete', userName, sysdate, 'Producto');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Update', userName, sysdate, 'Producto');
  END IF;
END;



--trigger Inventario  
CREATE or replace TRIGGER Inventario_trg_axr AFTER INSERT OR DELETE OR UPDATE
  ON Inventario FOR EACH ROW
DECLARE
userName varchar(100);
BEGIN
  select user into userName from dual;
  IF INSERTING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Insert', userName, sysdate, 'Inventario');
  ELSIF DELETING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Delete', userName, sysdate, 'Inventario');
  ELSIF UPDATING THEN
    insert into Bitacora 
    values (sec_bitacora.nextval,'Update', userName, sysdate, 'Inventario');
  END IF;
END;


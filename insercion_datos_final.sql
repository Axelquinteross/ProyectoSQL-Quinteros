USE tienda_repuestos;

INSERT INTO categorias (id_categoria, nombre) VALUES (1,'Filtros') ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);
INSERT INTO categorias (id_categoria, nombre) VALUES (2,'Aceites') ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);
INSERT INTO categorias (id_categoria, nombre) VALUES (3,'Frenos') ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

INSERT INTO proveedores (id_proveedor, nombre) VALUES (1,'ACME Parts') ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);
INSERT INTO proveedores (id_proveedor, nombre) VALUES (2,'MotorOil SA') ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

INSERT INTO productos (id_producto, nombre, id_categoria, id_proveedor, precio, stock) VALUES (1,'Filtro de Aire',1,1,8500.00,50)
ON DUPLICATE KEY UPDATE precio=VALUES(precio),stock=VALUES(stock);
INSERT INTO productos (id_producto, nombre, id_categoria, id_proveedor, precio, stock) VALUES (2,'Aceite 5W30 1L',2,2,12500.00,100)
ON DUPLICATE KEY UPDATE precio=VALUES(precio),stock=VALUES(stock);
INSERT INTO productos (id_producto, nombre, id_categoria, id_proveedor, precio, stock) VALUES (3,'Pastillas de Freno',3,1,22000.00,30)
ON DUPLICATE KEY UPDATE precio=VALUES(precio),stock=VALUES(stock);

INSERT INTO clientes (id_cliente, nombre, email, telefono, fecha_alta) VALUES (1,'Juan Pérez','juan.perez@example.com','351-555-1111',NOW())
ON DUPLICATE KEY UPDATE email=VALUES(email);
INSERT INTO clientes (id_cliente, nombre, email, telefono, fecha_alta) VALUES (2,'María López','maria.lopez@example.com','351-555-2222',NOW())
ON DUPLICATE KEY UPDATE email=VALUES(email);

SET @id_venta := NULL;
CALL sp_crear_venta(1,@id_venta);
CALL sp_agregar_item(@id_venta,1,2,(SELECT precio FROM productos WHERE id_producto=1));
CALL sp_agregar_item(@id_venta,2,1,(SELECT precio FROM productos WHERE id_producto=2));
CALL sp_confirmar_venta(@id_venta);

SELECT * FROM ventas;
SELECT * FROM detalle_venta;
SELECT * FROM productos;
USE tienda_repuestos;

SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER //

DROP FUNCTION IF EXISTS fn_calcular_total_venta;
CREATE FUNCTION fn_calcular_total_venta(p_id_venta INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT IFNULL(SUM(d.cantidad * d.precio_unitario), 0)
      INTO v_total
      FROM detalle_venta d
     WHERE d.id_venta = p_id_venta;
    RETURN v_total;
END//

DROP FUNCTION IF EXISTS fn_total_ventas_cliente;
CREATE FUNCTION fn_total_ventas_cliente(p_id_cliente INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT IFNULL(SUM(d.cantidad * d.precio_unitario), 0)
      INTO v_total
      FROM ventas v
      JOIN detalle_venta d ON d.id_venta = v.id_venta
     WHERE v.id_cliente = p_id_cliente;
    RETURN v_total;
END//

DROP FUNCTION IF EXISTS fn_stock_disponible;
CREATE FUNCTION fn_stock_disponible(p_id_producto INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock INT;
    SELECT stock INTO v_stock FROM productos WHERE id_producto = p_id_producto;
    RETURN IFNULL(v_stock, 0);
END//

DROP FUNCTION IF EXISTS fn_precio_con_descuento;
CREATE FUNCTION fn_precio_con_descuento(p_precio DECIMAL(10,2), p_descuento DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(p_precio * (1 - (p_descuento/100)), 2);
END//

DROP PROCEDURE IF EXISTS sp_crear_venta;
CREATE PROCEDURE sp_crear_venta(IN p_id_cliente INT, OUT p_id_venta INT)
BEGIN
    INSERT INTO ventas (id_cliente, fecha, total, estado)
    VALUES (p_id_cliente, NOW(), 0, 'ABIERTA');
    SET p_id_venta = LAST_INSERT_ID();
END//

DROP PROCEDURE IF EXISTS sp_agregar_item;
CREATE PROCEDURE sp_agregar_item(
    IN p_id_venta INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_precio_unitario DECIMAL(10,2)
)
BEGIN
    INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (p_id_venta, p_id_producto, p_cantidad, p_precio_unitario);

    UPDATE ventas
       SET total = fn_calcular_total_venta(p_id_venta)
     WHERE id_venta = p_id_venta;
END//

DROP PROCEDURE IF EXISTS sp_confirmar_venta;
CREATE PROCEDURE sp_confirmar_venta(IN p_id_venta INT)
BEGIN
    UPDATE ventas
       SET total = fn_calcular_total_venta(p_id_venta),
           estado = 'CERRADA'
     WHERE id_venta = p_id_venta;
END//

DROP TRIGGER IF EXISTS trg_detalle_venta_bi_validar_stock;
CREATE TRIGGER trg_detalle_venta_bi_validar_stock
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    SELECT stock INTO v_stock FROM productos WHERE id_producto = NEW.id_producto;
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto inexistente';
    END IF;
    IF NEW.cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad debe ser positiva';
    END IF;
    IF NEW.cantidad > v_stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
END//

DROP TRIGGER IF EXISTS trg_detalle_venta_ai_descontar_stock;
CREATE TRIGGER trg_detalle_venta_ai_descontar_stock
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    UPDATE productos
       SET stock = stock - NEW.cantidad
     WHERE id_producto = NEW.id_producto;
END//

DROP TRIGGER IF EXISTS trg_detalle_venta_au_ajustar_stock;
CREATE TRIGGER trg_detalle_venta_au_ajustar_stock
AFTER UPDATE ON detalle_venta
FOR EACH ROW
BEGIN
    DECLARE v_delta INT;
    SET v_delta = NEW.cantidad - OLD.cantidad;
    IF v_delta <> 0 THEN
        UPDATE productos
           SET stock = stock - v_delta
         WHERE id_producto = NEW.id_producto;
    END IF;
END//

DROP TRIGGER IF EXISTS trg_detalle_venta_ad_devolver_stock;
CREATE TRIGGER trg_detalle_venta_ad_devolver_stock
AFTER DELETE ON detalle_venta
FOR EACH ROW
BEGIN
    UPDATE productos
       SET stock = stock + OLD.cantidad
     WHERE id_producto = OLD.id_producto;
END//

DROP TRIGGER IF EXISTS trg_productos_bi_normalizar;
CREATE TRIGGER trg_productos_bi_normalizar
BEFORE INSERT ON productos
FOR EACH ROW
BEGIN
    SET NEW.nombre = TRIM(NEW.nombre);
END//

DELIMITER ;
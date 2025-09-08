-- Archivo: Idea+Quinteros_simple.sql
-- Versión simple, para entender lo básico

CREATE DATABASE IF NOT EXISTS tienda_repuestos;
USE tienda_repuestos;

-- Categorías de productos
CREATE TABLE categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100),
  descripcion TEXT
);

-- Proveedores
CREATE TABLE proveedores (
  id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150),
  telefono VARCHAR(50),
  email VARCHAR(150)
);

-- Clientes
CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150),
  documento VARCHAR(30),
  telefono VARCHAR(50),
  email VARCHAR(150)
);

-- Usuarios (personas que usan el sistema)
CREATE TABLE usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(80),
  nombre_completo VARCHAR(150),
  rol VARCHAR(50)
);

-- Productos
CREATE TABLE productos (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(200),
  precio DECIMAL(10,2),
  stock INT,
  id_categoria INT,
  FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

-- Compras (encabezado)
CREATE TABLE compras (
  id_compra INT AUTO_INCREMENT PRIMARY KEY,
  id_proveedor INT,
  fecha DATE,
  total DECIMAL(10,2),
  FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

-- Detalle de compra
CREATE TABLE detalle_compra (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_compra INT,
  id_producto INT,
  cantidad INT,
  precio DECIMAL(10,2),
  FOREIGN KEY (id_compra) REFERENCES compras(id_compra),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Ventas (encabezado)
CREATE TABLE ventas (
  id_venta INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT,
  fecha DATE,
  total DECIMAL(10,2),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

-- Detalle de venta
CREATE TABLE detalle_venta (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_venta INT,
  id_producto INT,
  cantidad INT,
  precio DECIMAL(10,2),
  FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

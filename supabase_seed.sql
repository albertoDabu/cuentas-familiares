/*
=============================================================================
SCRIPT DE SEMILLA (SEED) - CATEGORÍAS Y SUBCATEGORÍAS 💾
=============================================================================
Este script utiliza cadenas 'WITH' para insertar todo de una vez sin 
necesidad de bloques 'DO', lo cual es más compatible con el editor.

INSTRUCCIONES:
1. Sustituye 'TU_UUID_AQUÍ' por tu ID de usuario (de auth.users).
2. Dale al botón 'RUN'.
=============================================================================
*/

-- SUSTITUIR 'TU_UUID_AQUÍ' POR TU UUID REAL EN TODAS LAS LÍNEAS
-- (Usa Buscar y Reemplazar: Ctrl+H)

WITH 
cat_vivienda AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Vivienda', 'g2') RETURNING id, user_id
),
cat_suministros AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Suministros', 'g2') RETURNING id, user_id
),
cat_transporte AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Transporte', 'g2') RETURNING id, user_id
),
cat_alimentacion AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Alimentacion - Hogar', 'g2') RETURNING id, user_id
),
cat_salud AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Salud - Belleza', 'g2') RETURNING id, user_id
),
cat_educacion AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Educación - Formación', 'g2') RETURNING id, user_id
),
cat_ropa AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Ropa - Equipos', 'g2') RETURNING id, user_id
),
cat_ocio AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Social - Ocio - Deporte', 'g2') RETURNING id, user_id
),
cat_donativos AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) 
    VALUES ('TU_UUID_AQUÍ', 'Donativos', 'g2') RETURNING id, user_id
),
-- Inserción de Ingresos (sin subcategorías por ahora)
ingresos AS (
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES 
    ('TU_UUID_AQUÍ', 'Salarios', 'g1'),
    ('TU_UUID_AQUÍ', 'Bonificaciones', 'g1'),
    ('TU_UUID_AQUÍ', 'Alquileres', 'g1'),
    ('TU_UUID_AQUÍ', 'Negocios', 'g1'),
    ('TU_UUID_AQUÍ', 'Otros ingresos', 'g1')
)

-- Inserción de subcategorías vinculadas
INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
-- Vivienda
((SELECT user_id FROM cat_vivienda), (SELECT id FROM cat_vivienda), 'Alquiler / Hipoteca'),
((SELECT user_id FROM cat_vivienda), (SELECT id FROM cat_vivienda), 'Gastos Comunidad'),
((SELECT user_id FROM cat_vivienda), (SELECT id FROM cat_vivienda), 'Gastos IBI'),
((SELECT user_id FROM cat_vivienda), (SELECT id FROM cat_vivienda), 'Seguro Hogar'),
-- Suministros
((SELECT user_id FROM cat_suministros), (SELECT id FROM cat_suministros), 'Luz'),
((SELECT user_id FROM cat_suministros), (SELECT id FROM cat_suministros), 'Agua'),
((SELECT user_id FROM cat_suministros), (SELECT id FROM cat_suministros), 'Gas'),
((SELECT user_id FROM cat_suministros), (SELECT id FROM cat_suministros), 'Internet y Telefono'),
-- Transporte
((SELECT user_id FROM cat_transporte), (SELECT id FROM cat_transporte), 'Moto'),
((SELECT user_id FROM cat_transporte), (SELECT id FROM cat_transporte), 'Gasolina'),
((SELECT user_id FROM cat_transporte), (SELECT id FROM cat_transporte), 'Transporte publico'),
((SELECT user_id FROM cat_transporte), (SELECT id FROM cat_transporte), 'Parking'),
((SELECT user_id FROM cat_transporte), (SELECT id FROM cat_transporte), 'Otros vehículos'),
-- Alimentación
((SELECT user_id FROM cat_alimentacion), (SELECT id FROM cat_alimentacion), 'Alimentación'),
((SELECT user_id FROM cat_alimentacion), (SELECT id FROM cat_alimentacion), 'Limpieza / Higiene'),
((SELECT user_id FROM cat_alimentacion), (SELECT id FROM cat_alimentacion), 'Reparaciones hogar'),
((SELECT user_id FROM cat_alimentacion), (SELECT id FROM cat_alimentacion), 'Equipo hogar'),
((SELECT user_id FROM cat_alimentacion), (SELECT id FROM cat_alimentacion), 'Mobiliario'),
((SELECT user_id FROM cat_alimentacion), (SELECT id FROM cat_alimentacion), 'Servicio limpieza'),
-- Salud
((SELECT user_id FROM cat_salud), (SELECT id FROM cat_salud), 'Seguros'),
((SELECT user_id FROM cat_salud), (SELECT id FROM cat_salud), 'Medicamentos'),
((SELECT user_id FROM cat_salud), (SELECT id FROM cat_salud), 'Tratamientos especiales'),
-- Educación
((SELECT user_id FROM cat_educacion), (SELECT id FROM cat_educacion), 'Formación espirtiual'),
((SELECT user_id FROM cat_educacion), (SELECT id FROM cat_educacion), 'Guarderías y colegios'),
((SELECT user_id FROM cat_educacion), (SELECT id FROM cat_educacion), 'Canguros'),
-- Ropa
((SELECT user_id FROM cat_ropa), (SELECT id FROM cat_ropa), 'Ropa'),
((SELECT user_id FROM cat_ropa), (SELECT id FROM cat_ropa), 'Electronica'),
((SELECT user_id FROM cat_ropa), (SELECT id FROM cat_ropa), 'Otros equipos'),
-- Ocio
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Cuota Polo'),
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Viajes'),
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Planes Amigos'),
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Planes NA'),
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Eventos'),
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Regalos e Invitaciones'),
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Otros Deporte'),
((SELECT user_id FROM cat_ocio), (SELECT id FROM cat_ocio), 'Suscripciones'),
-- Donativos
((SELECT user_id FROM cat_donativos), (SELECT id FROM cat_donativos), 'Donaciones recurrentes'),
((SELECT user_id FROM cat_donativos), (SELECT id FROM cat_donativos), 'Donaciones esporádicas');

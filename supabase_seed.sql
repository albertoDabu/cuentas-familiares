/*
=============================================================================
SCRIPT DE SEMILLA (SEED) - CATEGORÍAS Y SUBCATEGORÍAS COMPLETAS 💾
=============================================================================
INSTRUCCIONES:
1. Regístrate en tu aplicación.
2. En el panel de Supabase, ve a 'Table Editor' -> 'auth.users' y copia tu ID (UUID).
3. Sustituye 'TU_UUID_AQUÍ' abajo por tu ID copiado.
4. Pega todo este código en el 'SQL Editor' de Supabase y dale a 'Run'.
=============================================================================
*/

DO $$
DECLARE
    uid UUID := 'TU_UUID_AQUÍ'; -- <--- 1. PEGA TU ID AQUÍ ENTRE LAS COMILLAS
    cat_id UUID;
BEGIN
    -- ==========================================
    -- GASTOS (g2)
    -- ==========================================

    -- 1. Vivienda
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Vivienda', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Alquiler / Hipoteca'), 
    (uid, cat_id, 'Gastos Comunidad'), 
    (uid, cat_id, 'Gastos IBI'), 
    (uid, cat_id, 'Seguro Hogar');

    -- 2. Suministros
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Suministros', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Luz'), 
    (uid, cat_id, 'Agua'), 
    (uid, cat_id, 'Gas'), 
    (uid, cat_id, 'Internet y Telefono');

    -- 3. Transporte
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Transporte', 'g1') -- g1?? No, g2
    RETURNING id INTO cat_id;
    UPDATE categorias SET grupo_id = 'g2' WHERE id = cat_id; -- Aseguramos Gasto
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Moto'), 
    (uid, cat_id, 'Gasolina'), 
    (uid, cat_id, 'Transporte publico'), 
    (uid, cat_id, 'Parking'), 
    (uid, cat_id, 'Otros vehículos');

    -- 4. Alimentacion - Hogar
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Alimentacion - Hogar', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Alimentación'), 
    (uid, cat_id, 'Limpieza / Higiene'), 
    (uid, cat_id, 'Reparaciones hogar'), 
    (uid, cat_id, 'Equipo hogar'), 
    (uid, cat_id, 'Mobiliario'), 
    (uid, cat_id, 'Servicio limpieza');

    -- 5. Salud - Belleza
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Salud - Belleza', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Seguros'), 
    (uid, cat_id, 'Medicamentos'), 
    (uid, cat_id, 'Tratamientos especiales');

    -- 6. Educación - Formación
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Educación - Formación', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Formación espirtiual'), 
    (uid, cat_id, 'Guarderías y colegios'), 
    (uid, cat_id, 'Canguros');

    -- 7. Ropa - Equipos
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Ropa - Equipos', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Ropa'), 
    (uid, cat_id, 'Electronica'), 
    (uid, cat_id, 'Otros equipos');

    -- 8. Social - Ocio - Deporte
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Social - Ocio - Deporte', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Cuota Polo'), 
    (uid, cat_id, 'Viajes'), 
    (uid, cat_id, 'Planes Amigos'), 
    (uid, cat_id, 'Planes NA'), 
    (uid, cat_id, 'Eventos'), 
    (uid, cat_id, 'Regalos e Invitaciones'), 
    (uid, cat_id, 'Otros Deporte'), 
    (uid, cat_id, 'Suscripciones');

    -- 9. Donativos
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Donativos', 'g2') RETURNING id INTO cat_id;
    INSERT INTO subcategorias (user_id, categoria_id, nombre) VALUES 
    (uid, cat_id, 'Donaciones recurrentes'), 
    (uid, cat_id, 'Donaciones esporádicas');


    -- ==========================================
    -- INGRESOS (g1)
    -- ==========================================

    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Salarios', 'g1');
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Bonificaciones', 'g1');
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Alquileres', 'g1');
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Negocios', 'g1');
    INSERT INTO categorias (user_id, nombre, grupo_id) VALUES (uid, 'Otros ingresos', 'g1');

END $$;

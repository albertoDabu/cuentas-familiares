/*
=============================================================================
AUTOMATIZACIÓN DE CATEGORÍAS POR DEFECTO 🤖🏠
=============================================================================
INSTRUCCIONES:
1. Copia todo este código.
2. Ve al 'SQL Editor' de tu panel de Supabase.
3. Pega el código en una 'New Query' y dale a 'Run'.
=============================================================================
Este script creará una función que se ejecuta cada vez que un nuevo usuario 
se registra, creando automáticamente toda la estructura de categorías.
=============================================================================
*/

-- 1. Función manejadora
CREATE OR REPLACE FUNCTION public.handle_new_user_setup()
RETURNS TRIGGER AS $$
DECLARE
    cat_id UUID;
BEGIN
    -- ==========================================
    -- GASTOS (g2)
    -- ==========================================

    -- Vivienda
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Vivienda', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Alquiler / Hipoteca'), 
    (NEW.id, cat_id, 'Gastos Comunidad'), 
    (NEW.id, cat_id, 'Gastos IBI'), 
    (NEW.id, cat_id, 'Seguro Hogar');

    -- Suministros
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Suministros', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Luz'), 
    (NEW.id, cat_id, 'Agua'), 
    (NEW.id, cat_id, 'Gas'), 
    (NEW.id, cat_id, 'Internet y Telefono');

    -- Transporte
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Transporte', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Moto'), 
    (NEW.id, cat_id, 'Gasolina'), 
    (NEW.id, cat_id, 'Transporte publico'), 
    (NEW.id, cat_id, 'Parking'), 
    (NEW.id, cat_id, 'Otros vehículos');

    -- Alimentacion - Hogar
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Alimentacion - Hogar', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Alimentación'), 
    (NEW.id, cat_id, 'Limpieza / Higiene'), 
    (NEW.id, cat_id, 'Reparaciones hogar'), 
    (NEW.id, cat_id, 'Equipo hogar'), 
    (NEW.id, cat_id, 'Mobiliario'), 
    (NEW.id, cat_id, 'Servicio limpieza');

    -- Salud - Belleza
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Salud - Belleza', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Seguros'), 
    (NEW.id, cat_id, 'Medicamentos'), 
    (NEW.id, cat_id, 'Tratamientos especiales');

    -- Educación - Formación
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Educación - Formación', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Formación espirtiual'), 
    (NEW.id, cat_id, 'Guarderías y colegios'), 
    (NEW.id, cat_id, 'Canguros');

    -- Ropa - Equipos
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Ropa - Equipos', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Ropa'), 
    (NEW.id, cat_id, 'Electronica'), 
    (NEW.id, cat_id, 'Otros equipos');

    -- Social - Ocio - Deporte
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Social - Ocio - Deporte', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Cuota Polo'), 
    (NEW.id, cat_id, 'Viajes'), 
    (NEW.id, cat_id, 'Planes Amigos'), 
    (NEW.id, cat_id, 'Planes NA'), 
    (NEW.id, cat_id, 'Eventos'), 
    (NEW.id, cat_id, 'Regalos e Invitaciones'), 
    (NEW.id, cat_id, 'Otros Deporte'), 
    (NEW.id, cat_id, 'Suscripciones');

    -- Donativos
    INSERT INTO public.categorias (user_id, nombre, grupo_id) 
    VALUES (NEW.id, 'Donativos', 'g2') RETURNING id INTO cat_id;
    INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
    (NEW.id, cat_id, 'Donaciones recurrentes'), 
    (NEW.id, cat_id, 'Donaciones esporádicas');

    -- ==========================================
    -- INGRESOS (g1)
    -- ==========================================

    INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (NEW.id, 'Salarios', 'g1');
    INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (NEW.id, 'Bonificaciones', 'g1');
    INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (NEW.id, 'Alquileres', 'g1');
    INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (NEW.id, 'Negocios', 'g1');
    INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (NEW.id, 'Otros ingresos', 'g1');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Trigger sobre la tabla de autenticación
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_setup();

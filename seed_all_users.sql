/*
=============================================================================
SCRIPT PRO PARA SEMBRAR TODOS LOS USUARIOS 🌱👥
=============================================================================
Este script procesa a TODOS los usuarios y devuelve un resumen.
Si un usuario ya tiene categorías, lo saltará automáticamente.

INSTRUCCIONES:
1. Dale a "RUN".
2. Mira la pestaña de resultados para ver cuántos usuarios se han sembrado.
=============================================================================
*/

CREATE OR REPLACE FUNCTION public.tmp_seed_all_users_report() 
RETURNS TABLE(usuario_id UUID, estado TEXT) AS $$
DECLARE
    user_record RECORD;
    cat_id UUID;
    added_count INTEGER := 0;
BEGIN
    FOR user_record IN SELECT id FROM auth.users LOOP
        IF NOT EXISTS (SELECT 1 FROM public.categorias WHERE user_id = user_record.id) THEN
            
            -- GASTOS (g2)
            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Vivienda', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Alquiler / Hipoteca'), 
            (user_record.id, cat_id, 'Gastos Comunidad'), 
            (user_record.id, cat_id, 'Gastos IBI'), 
            (user_record.id, cat_id, 'Seguro Hogar');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Suministros', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Luz'), 
            (user_record.id, cat_id, 'Agua'), 
            (user_record.id, cat_id, 'Gas'), 
            (user_record.id, cat_id, 'Internet y Telefono');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Transporte', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Moto'), 
            (user_record.id, cat_id, 'Gasolina'), 
            (user_record.id, cat_id, 'Transporte publico'), 
            (user_record.id, cat_id, 'Parking'), 
            (user_record.id, cat_id, 'Otros vehículos');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Alimentacion - Hogar', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Alimentación'), 
            (user_record.id, cat_id, 'Limpieza / Higiene'), 
            (user_record.id, cat_id, 'Reparaciones hogar'), 
            (user_record.id, cat_id, 'Equipo hogar'), 
            (user_record.id, cat_id, 'Mobiliario'), 
            (user_record.id, cat_id, 'Servicio limpieza');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Salud - Belleza', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Seguros'), 
            (user_record.id, cat_id, 'Medicamentos'), 
            (user_record.id, cat_id, 'Tratamientos especiales');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Educación - Formación', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Formación espirtiual'), 
            (user_record.id, cat_id, 'Guarderías y colegios'), 
            (user_record.id, cat_id, 'Canguros');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Ropa - Equipos', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Ropa'), 
            (user_record.id, cat_id, 'Electronica'), 
            (user_record.id, cat_id, 'Otros equipos');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Social - Ocio - Deporte', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Cuota Polo'), 
            (user_record.id, cat_id, 'Viajes'), 
            (user_record.id, cat_id, 'Planes Amigos'), 
            (user_record.id, cat_id, 'Planes NA'), 
            (user_record.id, cat_id, 'Eventos'), 
            (user_record.id, cat_id, 'Regalos e Invitaciones'), 
            (user_record.id, cat_id, 'Otros Deporte'), 
            (user_record.id, cat_id, 'Suscripciones');

            INSERT INTO public.categorias (user_id, nombre, grupo_id) 
            VALUES (user_record.id, 'Donativos', 'g2') RETURNING id INTO cat_id;
            INSERT INTO public.subcategorias (user_id, categoria_id, nombre) VALUES 
            (user_record.id, cat_id, 'Donaciones recurrentes'), 
            (user_record.id, cat_id, 'Donaciones esporádicas');

            -- INGRESOS (g1)
            INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (user_record.id, 'Salarios', 'g1');
            INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (user_record.id, 'Bonificaciones', 'g1');
            INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (user_record.id, 'Alquileres', 'g1');
            INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (user_record.id, 'Negocios', 'g1');
            INSERT INTO public.categorias (user_id, nombre, grupo_id) VALUES (user_record.id, 'Otros ingresos', 'g1');

            usuario_id := user_record.id;
            estado := 'SEMBRADO CON ÉXITO';
            RETURN NEXT;
        ELSE
            usuario_id := user_record.id;
            estado := 'YA TENÍA DATOS (OMITIDO)';
            RETURN NEXT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ejecutar y ver resultados
SELECT * FROM public.tmp_seed_all_users_report();

-- Opcional: Borrar función después de ver el resultado
-- DROP FUNCTION public.tmp_seed_all_users_report();

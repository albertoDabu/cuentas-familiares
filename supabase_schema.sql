-- TABLA: categorias
CREATE TABLE categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users NOT NULL DEFAULT auth.uid(),
    nombre TEXT NOT NULL,
    grupo_id TEXT NOT NULL, -- 'g1' (Ingresos), 'g2' (Gastos)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABLA: subcategorias
CREATE TABLE subcategorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users NOT NULL DEFAULT auth.uid(),
    categoria_id UUID REFERENCES categorias ON DELETE CASCADE NOT NULL,
    nombre TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- TABLA: registros
CREATE TABLE registros (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users NOT NULL DEFAULT auth.uid(),
    subcategoria_id UUID REFERENCES subcategorias ON DELETE CASCADE NOT NULL,
    mes INTEGER NOT NULL,
    fecha DATE NOT NULL,
    concepto TEXT NOT NULL,
    importe DECIMAL(12, 2) NOT NULL,
    comentarios TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- HABILITAR RLS (Row Level Security)
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE subcategorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE registros ENABLE ROW LEVEL SECURITY;

-- POLÍTICAS DE SEGURIDAD (Cada usuario solo ve lo suyo)
CREATE POLICY "Usuarios pueden ver sus categorías" ON categorias FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden insertar sus categorías" ON categorias FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden editar sus categorías" ON categorias FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden borrar sus categorías" ON categorias FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden ver sus subcategorías" ON subcategorias FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden insertar sus subcategorías" ON subcategorias FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden editar sus subcategorías" ON subcategorias FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden borrar sus subcategorías" ON subcategorias FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden ver sus registros" ON registros FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden insertar sus registros" ON registros FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden editar sus registros" ON registros FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Usuarios pueden borrar sus registros" ON registros FOR DELETE USING (auth.uid() = user_id);

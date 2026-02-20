import { writable, derived } from 'svelte/store';
import { supabase } from './supabaseClient';
import { authState } from './auth.svelte.js';

// Estado inicial vacío
const initialData = {
  categorias: [],
  subcategorias: [],
  registros: []
};

export const dbStore = writable(initialData);

// Cargador de datos desde Supabase
async function refreshData() {
  if (!authState.user) return;

  console.log("Cargando datos para el usuario:", authState.user.id);

  const [catRes, subRes, regRes] = await Promise.all([
    supabase.from('categorias').select('*'),
    supabase.from('subcategorias').select('*'),
    supabase.from('registros').select('*')
  ]);

  if (catRes.error) console.error("Error cargando categorías:", catRes.error);
  if (subRes.error) console.error("Error cargando subcategorías:", subRes.error);
  if (regRes.error) console.error("Error cargando registros:", regRes.error);

  console.log("Datos recibidos:", { 
    cats: catRes.data?.length, 
    subs: subRes.data?.length, 
    regs: regRes.data?.length 
  });

  dbStore.set({
    categorias: (catRes.data || []).map(c => ({
      id: c.id,
      nombre: c.nombre,
      grupoId: c.grupo_id
    })),
    subcategorias: (subRes.data || []).map(s => ({
      id: s.id,
      nombre: s.nombre,
      categoriaId: s.categoria_id
    })),
    registros: (regRes.data || []).map(r => ({
      id: r.id,
      mes: r.mes,
      subcategoriaId: r.subcategoria_id,
      concepto: r.concepto,
      importe: Number(r.importe),
      fecha: r.fecha,
      comentarios: r.comentarios
    }))
  });
}

// Feedback Store (Toast)
export const feedback = writable({ show: false, message: '', type: 'success' });

/**
 * @param {string} message
 * @param {'success' | 'error' | 'info'} type
 */
export function showToast(message, type = 'success') {
  feedback.set({ show: true, message, type });
  setTimeout(() => {
    feedback.set({ show: false, message: '', type: 'success' });
  }, 3000);
}



// Derived stores for easier access
export const categorias = derived(dbStore, ($db) => $db.categorias);
export const subcategorias = derived(dbStore, ($db) => $db.subcategorias);
export const registros = derived(dbStore, ($db) => $db.registros);

// Actions
export const dbActions = {
  addCategoria: async (nombre, grupoId) => {
    const { data, error } = await supabase
      .from('categorias')
      .insert([{ nombre, grupo_id: grupoId }])
      .select();
    
    if (!error) {
      const newCat = { id: data[0].id, nombre: data[0].nombre, grupoId: data[0].grupo_id };
      dbStore.update(db => ({ ...db, categorias: [...db.categorias, newCat] }));
      showToast("Categoría añadida con éxito", "success");
    } else {
      showToast("Error al añadir categoría: " + error.message, "error");
    }
  },

  updateCategoria: async (id, nombre) => {
    const { error } = await supabase
      .from('categorias')
      .update({ nombre })
      .eq('id', id);
    
    if (!error) {
      dbStore.update(db => ({
        ...db,
        categorias: db.categorias.map(c => c.id === id ? { ...c, nombre } : c)
      }));
      showToast("Categoría actualizada", "success");
    } else {
      showToast("Error al actualizar categoría", "error");
    }
  },

  deleteCategoria: async (id) => {
    const { error } = await supabase.from('categorias').delete().eq('id', id);
    if (!error) {
      dbStore.update(db => {
        const subIdsForCat = db.subcategorias.filter(s => s.categoriaId === id).map(s => s.id);
        return {
          ...db,
          categorias: db.categorias.filter(c => c.id !== id),
          subcategorias: db.subcategorias.filter(s => s.categoriaId !== id),
          registros: db.registros.filter(r => !subIdsForCat.includes(r.subcategoriaId))
        };
      });
      showToast("Categoría eliminada", "success");
    } else {
      showToast("Error al eliminar categoría", "error");
    }
  },

  addSubcategoria: async (nombre, categoriaId) => {
    const { data, error } = await supabase
      .from('subcategorias')
      .insert([{ nombre, categoria_id: categoriaId }])
      .select();
    
    if (!error) {
      const newSub = { id: data[0].id, nombre: data[0].nombre, categoriaId: data[0].categoria_id };
      dbStore.update(db => ({ ...db, subcategorias: [...db.subcategorias, newSub] }));
      showToast("Subcategoría añadida", "success");
    } else {
      showToast("Error al añadir subcategoría", "error");
    }
  },

  updateSubcategoria: async (id, nombre) => {
    const { error } = await supabase
      .from('subcategorias')
      .update({ nombre })
      .eq('id', id);
    
    if (!error) {
      dbStore.update(db => ({
        ...db,
        subcategorias: db.subcategorias.map(s => s.id === id ? { ...s, nombre } : s)
      }));
      showToast("Subcategoría actualizada", "success");
    } else {
      showToast("Error al actualizar subcategoría", "error");
    }
  },

  deleteSubcategoria: async (id) => {
    const { error } = await supabase.from('subcategorias').delete().eq('id', id);
    if (!error) {
      dbStore.update(db => ({
        ...db,
        subcategorias: db.subcategorias.filter(s => s.id !== id),
        registros: db.registros.filter(r => r.subcategoriaId !== id)
      }));
      showToast("Subcategoría eliminada", "success");
    } else {
      showToast("Error al eliminar subcategoría", "error");
    }
  },

  addRegistro: async (mes, subcategoriaId, concepto, importe, fecha, comentarios) => {
    const { data, error } = await supabase
      .from('registros')
      .insert([{ 
        mes, 
        subcategoria_id: subcategoriaId, 
        concepto, 
        importe, 
        fecha, 
        comentarios 
      }])
      .select();
    
    if (!error) {
      const r = data[0];
      const newReg = {
        id: r.id,
        mes: r.mes,
        subcategoriaId: r.subcategoria_id,
        concepto: r.concepto,
        importe: Number(r.importe),
        fecha: r.fecha,
        comentarios: r.comentarios
      };
      dbStore.update(db => ({ ...db, registros: [...db.registros, newReg] }));
      showToast("Registro guardado con éxito", "success");
    } else {
      showToast("Error al guardar registro", "error");
    }
  },

  updateRegistro: async (id, mes, subcategoriaId, concepto, importe, fecha, comentarios) => {
    const { error } = await supabase
      .from('registros')
      .update({ 
        mes, 
        subcategoria_id: subcategoriaId, 
        concepto, 
        importe, 
        fecha, 
        comentarios 
      })
      .eq('id', id);
    
    if (!error) {
      dbStore.update(db => ({
        ...db,
        registros: db.registros.map(r => r.id === id ? { 
          ...r, mes, subcategoriaId, concepto, importe, fecha, comentarios 
        } : r)
      }));
      showToast("Registro actualizado", "success");
    } else {
      showToast("Error al actualizar registro", "error");
    }
  },

  deleteRegistro: async (id) => {
    const { error } = await supabase.from('registros').delete().eq('id', id);
    if (!error) {
      dbStore.update(db => ({
        ...db,
        registros: db.registros.filter(r => r.id !== id)
      }));
      showToast("Registro eliminado", "success");
    } else {
      showToast("Error al eliminar registro", "error");
    }
  },

  refreshData,

  clearData: () => {
    dbStore.set(initialData);
  }
};

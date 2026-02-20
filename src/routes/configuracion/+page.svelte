<script>
  import { dbStore, dbActions } from "$lib/store.svelte.js";
  import Modal from "$lib/components/Modal.svelte";

  // State for Editing
  let editingId = $state(null);
  let editValue = $state("");

  // State for Modal
  let showModal = $state(false);
  let modalType = $state("categoria"); // 'categoria' or 'subcategoria'
  let modalParentId = $state(null); // grupoId for cat, categoriaId for sub
  let modalValue = $state("");

  function startEdit(id, currentNombre) {
    editingId = id;
    editValue = currentNombre;
  }

  function saveEdit(id, type) {
    if (editValue.trim()) {
      if (type === "categoria") {
        dbActions.updateCategoria(id, editValue);
      } else {
        dbActions.updateSubcategoria(id, editValue);
      }
    }
    editingId = null;
  }

  function handleKeydown(e, id, type) {
    if (e.key === "Enter") saveEdit(id, type);
    if (e.key === "Escape") editingId = null;
  }

  function confirmDelete(id, type, nombre) {
    const msg =
      type === "categoria"
        ? `¿Eliminar la categoría "${nombre}"? También se eliminarán todas sus subcategorías y registros asociados.`
        : `¿Eliminar la subcategoría "${nombre}"? También se eliminarán todos sus registros asociados.`;

    if (confirm(msg)) {
      if (type === "categoria") {
        dbActions.deleteCategoria(id);
      } else {
        dbActions.deleteSubcategoria(id);
      }
    }
  }

  function openAddModal(type, parentId) {
    modalType = type;
    modalParentId = parentId;
    modalValue = "";
    showModal = true;
  }

  function closeModal() {
    showModal = false;
  }

  function handleAdd() {
    if (modalValue.trim()) {
      if (modalType === "categoria") {
        dbActions.addCategoria(modalValue, modalParentId);
      } else {
        dbActions.addSubcategoria(modalValue, modalParentId);
      }
    }
    closeModal();
  }
</script>

<div class="flex flex-col min-h-screen">
  <!-- CONTENIDO: (Fondo Gris - Full Width) -->
  <section class="flex-1 bg-slate-50 py-12">
    <div class="max-w-7xl mx-auto px-6 space-y-10 relative">
      <div>
        <h2
          class="text-2xl sm:text-4xl font-black text-slate-800 tracking-tight"
        >
          Editar mis categorias
        </h2>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-12">
        <!-- Columna Ingresos -->
        <div class="space-y-6">
          <div
            class="flex justify-between items-center border-b border-green-200 pb-3"
          >
            <h3 class="text-xl font-bold text-green-700 tracking-tight">
              INGRESOS
            </h3>
            <button
              onclick={() => openAddModal("categoria", "g1")}
              class="text-sm font-bold bg-green-50 text-green-700 px-4 py-2 rounded-xl hover:bg-green-100 transition-all shadow-sm border border-green-100"
            >
              + Nueva Categoría
            </button>
          </div>

          <div class="space-y-4">
            {#each $dbStore.categorias.filter((c) => c.grupoId === "g1") as cat}
              <div
                class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden divide-y divide-slate-100"
              >
                <div
                  class="p-4 bg-slate-50/30 group transition-all hover:bg-indigo-50/30"
                >
                  <div class="flex justify-between items-center">
                    {#if editingId === cat.id}
                      <input
                        type="text"
                        bind:value={editValue}
                        onkeydown={(e) => handleKeydown(e, cat.id, "categoria")}
                        onblur={() => saveEdit(cat.id, "categoria")}
                        class="flex-1 px-3 py-1.5 bg-white border-2 border-indigo-400 rounded-lg outline-none font-bold"
                      />
                    {:else}
                      <div class="flex items-center gap-2 group/title">
                        <span class="font-bold text-slate-800 text-lg"
                          >{cat.nombre}</span
                        >
                        <button
                          onclick={() => startEdit(cat.id, cat.nombre)}
                          class="opacity-0 group-hover:opacity-100 transition-opacity p-1.5 hover:bg-white rounded-lg text-indigo-500 shadow-sm border border-slate-100"
                          title="Editar nombre"
                        >
                          ✏️
                        </button>
                      </div>
                    {/if}

                    <div class="flex gap-2">
                      <button
                        onclick={() => openAddModal("subcategoria", cat.id)}
                        class="text-xs font-bold bg-white text-slate-400 hover:text-indigo-600 px-2 py-1.5 rounded-lg border border-slate-200 transition-all hover:shadow-sm"
                      >
                        + Añadir Subcategoría
                      </button>
                      <button
                        onclick={() =>
                          confirmDelete(cat.id, "categoria", cat.nombre)}
                        class="text-xs p-1.5 text-slate-300 hover:text-red-500 transition-colors"
                      >
                        🗑
                      </button>
                    </div>
                  </div>
                </div>

                <ul class="p-2 space-y-1">
                  {#each $dbStore.subcategorias.filter((s) => s.categoriaId === cat.id) as sub}
                    <li
                      class="group flex justify-between items-center p-2 rounded-xl hover:bg-slate-50 transition-all"
                    >
                      {#if editingId === sub.id}
                        <input
                          type="text"
                          bind:value={editValue}
                          onkeydown={(e) =>
                            handleKeydown(e, sub.id, "subcategoria")}
                          onblur={() => saveEdit(sub.id, "subcategoria")}
                          class="flex-1 px-2 py-1 bg-white border-2 border-indigo-300 rounded-lg outline-none text-sm font-semibold"
                        />
                      {:else}
                        <div class="flex items-center gap-2">
                          <span class="text-sm font-semibold text-slate-600"
                            >{sub.nombre}</span
                          >
                          <button
                            onclick={() => startEdit(sub.id, sub.nombre)}
                            class="opacity-0 group-hover:opacity-100 transition-opacity text-[10px] p-1 h-5 w-5 flex items-center justify-center hover:bg-white rounded bg-slate-100 text-indigo-500 shadow-sm"
                          >
                            ✏️
                          </button>
                        </div>
                      {/if}
                      <button
                        onclick={() =>
                          confirmDelete(sub.id, "subcategoria", sub.nombre)}
                        class="opacity-0 group-hover:opacity-100 text-xs text-slate-300 hover:text-red-500 transition-all"
                      >
                        🗑
                      </button>
                    </li>
                  {/each}
                </ul>
              </div>
            {/each}
          </div>
        </div>

        <!-- Columna Gastos -->
        <div class="space-y-6">
          <div
            class="flex justify-between items-center border-b border-red-200 pb-3"
          >
            <h3 class="text-xl font-bold text-red-700 tracking-tight">
              GASTOS
            </h3>
            <button
              onclick={() => openAddModal("categoria", "g2")}
              class="text-sm font-bold bg-red-50 text-red-700 px-4 py-2 rounded-xl hover:bg-red-100 transition-all shadow-sm border border-red-100"
            >
              + Nueva Categoría
            </button>
          </div>

          <div class="space-y-4">
            {#each $dbStore.categorias.filter((c) => c.grupoId === "g2") as cat}
              <div
                class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden divide-y divide-slate-100"
              >
                <div
                  class="p-4 bg-slate-50/30 group transition-all hover:bg-indigo-50/30"
                >
                  <div class="flex justify-between items-center">
                    {#if editingId === cat.id}
                      <input
                        type="text"
                        bind:value={editValue}
                        onkeydown={(e) => handleKeydown(e, cat.id, "categoria")}
                        onblur={() => saveEdit(cat.id, "categoria")}
                        class="flex-1 px-3 py-1.5 bg-white border-2 border-indigo-400 rounded-lg outline-none font-bold"
                      />
                    {:else}
                      <div class="flex items-center gap-2 group/title">
                        <span class="font-bold text-slate-800 text-lg"
                          >{cat.nombre}</span
                        >
                        <button
                          onclick={() => startEdit(cat.id, cat.nombre)}
                          class="opacity-0 group-hover:opacity-100 transition-opacity p-1.5 hover:bg-white rounded-lg text-indigo-500 shadow-sm border border-slate-100"
                          title="Editar nombre"
                        >
                          ✏️
                        </button>
                      </div>
                    {/if}

                    <div class="flex gap-2">
                      <button
                        onclick={() => openAddModal("subcategoria", cat.id)}
                        class="text-xs font-bold bg-white text-slate-400 hover:text-indigo-600 px-2 py-1.5 rounded-lg border border-slate-200 transition-all hover:shadow-sm"
                      >
                        + Sub
                      </button>
                      <button
                        onclick={() =>
                          confirmDelete(cat.id, "categoria", cat.nombre)}
                        class="text-xs p-1.5 text-slate-300 hover:text-red-500 transition-colors"
                      >
                        🗑
                      </button>
                    </div>
                  </div>
                </div>

                <ul class="p-2 space-y-1">
                  {#each $dbStore.subcategorias.filter((s) => s.categoriaId === cat.id) as sub}
                    <li
                      class="group flex justify-between items-center p-2 rounded-xl hover:bg-slate-50 transition-all"
                    >
                      {#if editingId === sub.id}
                        <input
                          type="text"
                          bind:value={editValue}
                          onkeydown={(e) =>
                            handleKeydown(e, sub.id, "subcategoria")}
                          onblur={() => saveEdit(sub.id, "subcategoria")}
                          class="flex-1 px-2 py-1 bg-white border-2 border-indigo-300 rounded-lg outline-none text-sm font-semibold"
                        />
                      {:else}
                        <div class="flex items-center gap-2">
                          <span class="text-sm font-semibold text-slate-600"
                            >{sub.nombre}</span
                          >
                          <button
                            onclick={() => startEdit(sub.id, sub.nombre)}
                            class="opacity-0 group-hover:opacity-100 transition-opacity text-[10px] p-1 h-5 w-5 flex items-center justify-center hover:bg-white rounded bg-slate-100 text-indigo-500 shadow-sm"
                          >
                            ✏️
                          </button>
                        </div>
                      {/if}
                      <button
                        onclick={() =>
                          confirmDelete(sub.id, "subcategoria", sub.nombre)}
                        class="opacity-0 group-hover:opacity-100 text-xs text-slate-300 hover:text-red-500 transition-all"
                      >
                        🗑
                      </button>
                    </li>
                  {/each}
                </ul>
              </div>
            {/each}
          </div>
        </div>
      </div>

      <Modal
        show={showModal}
        title={`Añadir Nueva ${modalType === "categoria" ? "Categoría" : "Subcategoría"}`}
        onClose={closeModal}
      >
        <div class="space-y-6">
          <div class="space-y-4">
            <p class="text-slate-500 font-medium">
              Introduce el nombre para la nueva entrada.
            </p>
            <input
              type="text"
              bind:value={modalValue}
              placeholder="Ej: Mantenimiento, Gimnasio..."
              class="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-lg font-bold outline-none focus:border-indigo-400 focus:bg-white transition-all"
              onkeydown={(e) => e.key === "Enter" && handleAdd()}
            />
          </div>

          <div class="flex gap-4">
            <button
              onclick={closeModal}
              class="flex-1 bg-slate-100 hover:bg-slate-200 text-slate-600 font-black py-4 rounded-2xl transition-all uppercase tracking-widest text-xs"
            >
              Cancelar
            </button>
            <button
              onclick={handleAdd}
              class="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white font-black py-4 rounded-2xl shadow-xl shadow-indigo-100 transition-all active:scale-95 uppercase tracking-widest text-xs"
            >
              Confirmar
            </button>
          </div>
        </div>
      </Modal>
    </div>
  </section>
</div>

<style>
</style>

<script>
  import { dbStore, dbActions } from "$lib/store.svelte.js";
  import Dropdown from "$lib/components/Dropdown.svelte";
  import Modal from "$lib/components/Modal.svelte";

  const MESES = [
    "Ene",
    "Feb",
    "Mar",
    "Abr",
    "May",
    "Jun",
    "Jul",
    "Ago",
    "Sep",
    "Oct",
    "Nov",
    "Dic",
  ];

  const MES_OPTIONS = MESES.map((label, value) => ({ label, value }));

  let selectedGrupoId = $state("g2"); // Gastos por defecto
  let selectedCategoriaId = $state("");

  // Reset categoria when grupo changes
  $effect(() => {
    const cats = $dbStore.categorias.filter(
      (c) => c.grupoId === selectedGrupoId,
    );
    if (cats.length > 0 && !cats.find((c) => c.id === selectedCategoriaId)) {
      selectedCategoriaId = cats[0].id;
    }
  });

  // Form state
  let editingId = $state(null);
  let newMes = $state(new Date().getMonth());
  let newFecha = $state(new Date().toISOString().split("T")[0]);
  let newSubcategoriaId = $state("");
  let newConcepto = $state("");
  let newImporte = $state(0);
  let newComentarios = $state("");

  // Table State: Sorting & Filtering
  let sortKey = $state("fecha"); // 'fecha', 'subcategoria', 'concepto', 'importe'
  let sortDir = $state(-1); // 1 asc, -1 desc
  let globalSearch = $state("");
  let activeFilters = $state([]); // Array of { id, column, operator, value }

  const FILTER_COLUMNS = [
    { label: "Mes", value: "mes", type: "number" },
    { label: "Fecha", value: "fecha", type: "string" },
    { label: "Subcategoría", value: "subcategoria", type: "string" },
    { label: "Concepto", value: "concepto", type: "string" },
    { label: "Importe", value: "importe", type: "number" },
    { label: "Comentarios", value: "comentarios", type: "string" },
  ];

  const OPERATORS = {
    string: [
      { label: "Contiene", value: "contains" },
      { label: "Es igual a", value: "equals" },
      { label: "Empieza por", value: "starts" },
    ],
    number: [
      { label: "Es igual a", value: "eq" },
      { label: "Mayor que", value: "gt" },
      { label: "Menor que", value: "lt" },
      { label: "Mayor o igual que", value: "gte" },
      { label: "Menor o igual que", value: "lte" },
      { label: "Entre", value: "between" },
    ],
    date: [
      { label: "Es igual a", value: "equals" },
      { label: "Antes de", value: "lt" },
      { label: "Después de", value: "gt" },
      { label: "Entre", value: "between" },
    ],
  };

  // Modal Filter State
  let showFilterModal = $state(false);
  let filterCol = $state("concepto");
  let filterOp = $state("contains");
  let filterVal = $state("");
  let filterValEnd = $state(""); // For intervals
  let activeCell = $state(null); // { subId, mesIdx }

  // Update operator when column changes
  $effect(() => {
    const col = FILTER_COLUMNS.find((c) => c.value === filterCol);
    if (!col) return;
    const typeKey =
      col.type === "string" && col.value === "fecha" ? "date" : col.type;
    const ops = OPERATORS[typeKey];
    if (ops && !ops.find((o) => o.value === filterOp)) {
      filterOp = ops[0].value;
    }
  });

  // Derived data
  let subcategoriasFiltradas = $derived(() => {
    if (!$dbStore.categorias.some((c) => c.id === selectedCategoriaId))
      return [];
    return $dbStore.subcategorias.filter(
      (s) => s.categoriaId === selectedCategoriaId,
    );
  });

  let currentCategoria = $derived(
    $dbStore.categorias.find((c) => c.id === selectedCategoriaId),
  );

  let grupoOptions = [
    { label: "🟢 INGRESOS", value: "g1" },
    { label: "🔴 GASTOS", value: "g2" },
  ];

  let categoriaOptions = $derived(
    $dbStore.categorias
      .filter((c) => c.grupoId === selectedGrupoId)
      .map((c) => ({ label: c.nombre, value: c.id })),
  );

  let subcategoriaOptions = $derived(
    subcategoriasFiltradas().map((s) => ({ label: s.nombre, value: s.id })),
  );

  // Records Table Logic
  let filteredRecords = $derived(() => {
    let list = $dbStore.registros.filter((r) => {
      const sub = $dbStore.subcategorias.find((s) => s.id === r.subcategoriaId);
      return sub && sub.categoriaId === selectedCategoriaId;
    });

    // Global Search (All Fields)
    if (globalSearch) {
      const s = globalSearch.toLowerCase();
      list = list.filter((r) => {
        const mesName = (MESES[r.mes] || "").toLowerCase();
        const fecha = (r.fecha || "").toLowerCase();
        const subName = (
          $dbStore.subcategorias.find((sub) => sub.id === r.subcategoriaId)
            ?.nombre || ""
        ).toLowerCase();
        const concepto = r.concepto.toLowerCase();
        const comentarios = (r.comentarios || "").toLowerCase();
        const importe = String(r.importe);

        return (
          mesName.includes(s) ||
          fecha.includes(s) ||
          subName.includes(s) ||
          concepto.includes(s) ||
          comentarios.includes(s) ||
          importe.includes(s)
        );
      });
    }

    // Dynamic Filters
    activeFilters.forEach((f) => {
      list = list.filter((r) => {
        let val = r[f.column];
        if (f.column === "subcategoria") {
          val = r.subcategoriaId;
        }

        const filterVal = f.value;
        const filterValEnd = f.valueEnd;
        const targetVal = val;

        switch (f.operator) {
          case "contains":
            return String(targetVal)
              .toLowerCase()
              .includes(String(filterVal).toLowerCase());
          case "equals":
            return (
              String(targetVal).toLowerCase() ===
              String(filterVal).toLowerCase()
            );
          case "starts":
            return String(targetVal)
              .toLowerCase()
              .startsWith(String(filterVal).toLowerCase());
          case "eq":
            return Number(targetVal) === Number(filterVal);
          case "gt":
            return f.column === "fecha"
              ? targetVal && targetVal > filterVal
              : Number(targetVal) > Number(filterVal);
          case "lt":
            return f.column === "fecha"
              ? targetVal && targetVal < filterVal
              : Number(targetVal) < Number(filterVal);
          case "gte":
            return Number(targetVal) >= Number(filterVal);
          case "lte":
            return Number(targetVal) <= Number(filterVal);
          case "between":
            if (f.column === "fecha") {
              return (
                targetVal && targetVal >= filterVal && targetVal <= filterValEnd
              );
            }
            return (
              Number(targetVal) >= Number(filterVal) &&
              Number(targetVal) <= Number(filterValEnd)
            );
          default:
            return true;
        }
      });
    });

    // Sorting
    list.sort((a, b) => {
      let valA, valB;
      if (sortKey === "fecha") {
        valA = a.fecha || `2026-${String(a.mes + 1).padStart(2, "0")}-01`;
        valB = b.fecha || `2026-${String(b.mes + 1).padStart(2, "0")}-01`;
      } else if (sortKey === "subcategoria") {
        valA =
          $dbStore.subcategorias.find((s) => s.id === a.subcategoriaId)
            ?.nombre || "";
        valB =
          $dbStore.subcategorias.find((s) => s.id === b.subcategoriaId)
            ?.nombre || "";
      } else if (sortKey === "importe") {
        valA = a.importe;
        valB = b.importe;
      } else if (sortKey === "mes") {
        valA = a.mes;
        valB = b.mes;
      } else {
        valA = a[sortKey] || "";
        valB = b[sortKey] || "";
      }

      if (valA < valB) return -1 * sortDir;
      if (valA > valB) return 1 * sortDir;
      return 0;
    });

    return list;
  });

  function toggleSort(key) {
    if (sortKey === key) {
      sortDir *= -1;
    } else {
      sortKey = key;
      sortDir = 1;
    }
  }

  function getTotalSubMes(subId, mesIdx) {
    return $dbStore.registros
      .filter((r) => r.subcategoriaId === subId && r.mes === mesIdx)
      .reduce((acc, r) => acc + r.importe, 0);
  }

  function removeFilter(id) {
    const filterToRemove = activeFilters.find((f) => f.id === id);
    if (filterToRemove) {
      if (
        filterToRemove.column === "subcategoria" ||
        filterToRemove.column === "mes"
      ) {
        activeCell = null;
      }
    }
    activeFilters = activeFilters.filter((f) => f.id !== id);
  }

  function getFilterLabel(col, op, val, valEnd) {
    const colObj = FILTER_COLUMNS.find((c) => c.value === col);
    if (!colObj) return "Filtro";

    const typeKey =
      colObj.type === "string" && colObj.value === "fecha"
        ? "date"
        : colObj.type;

    const opObj = OPERATORS[typeKey]?.find((o) => o.value === op);
    let displayVal = val;
    let displayValEnd = valEnd;

    if (col === "mes") {
      displayVal = MESES[val];
    } else if (col === "subcategoria") {
      displayVal =
        $dbStore.subcategorias.find((s) => s.id === val)?.nombre || val;
    }

    if (op === "between") {
      return `${colObj.label} entre ${displayVal} y ${displayValEnd}`;
    }

    return `${colObj.label} ${opObj?.label || op} ${displayVal}`;
  }

  function applyCellFilter(subId, mesIdx) {
    // Clear existing filters for the same columns to avoid redundancy
    activeFilters = activeFilters.filter(
      (f) => f.column !== "subcategoria" && f.column !== "mes",
    );

    // Add Mes filter
    activeFilters.push({
      id: crypto.randomUUID(),
      column: "mes",
      operator: "eq",
      value: mesIdx,
      label: getFilterLabel("mes", "eq", mesIdx),
    });

    // Add Subcategoria filter
    activeFilters.push({
      id: crypto.randomUUID(),
      column: "subcategoria",
      operator: "equals",
      value: subId,
      label: getFilterLabel("subcategoria", "equals", subId),
    });

    // Scroll to records table
    const tableElement = document.getElementById("records-table-start");
    if (tableElement) {
      tableElement.scrollIntoView({ behavior: "smooth" });
    }

    // Set active cell for highlighting
    activeCell = { subId, mesIdx };
  }

  function addFilter() {
    const isValuePresent = filterVal !== "" || typeof filterVal === "number";
    const isEndValuePresent =
      filterOp !== "between" ||
      filterValEnd !== "" ||
      typeof filterValEnd === "number";

    if (isValuePresent && isEndValuePresent) {
      activeFilters.push({
        id: crypto.randomUUID(),
        column: filterCol,
        operator: filterOp,
        value: filterVal,
        valueEnd: filterValEnd,
        label: getFilterLabel(filterCol, filterOp, filterVal, filterValEnd),
      });
      showFilterModal = false;
      filterVal = "";
      filterValEnd = "";
      activeCell = null; // Manual filter clears cell highlight
    }
  }

  function saveRegistro() {
    if (newSubcategoriaId && newConcepto && newImporte > 0) {
      if (editingId) {
        dbActions.updateRegistro(
          editingId,
          newMes,
          newSubcategoriaId,
          newConcepto,
          newImporte,
          newFecha,
          newComentarios,
        );
      } else {
        dbActions.addRegistro(
          newMes,
          newSubcategoriaId,
          newConcepto,
          newImporte,
          newFecha,
          newComentarios,
        );
      }
      resetForm();
    }
  }

  function startEdit(reg) {
    editingId = reg.id;
    newMes = reg.mes;
    newFecha = reg.fecha || `2026-${String(reg.mes + 1).padStart(2, "0")}-01`;
    newSubcategoriaId = reg.subcategoriaId;
    newConcepto = reg.concepto;
    newImporte = reg.importe;
    newComentarios = reg.comentarios || "";
    showEditModal = true;
  }

  function resetForm() {
    editingId = null;
    showEditModal = false;
    newConcepto = "";
    newImporte = 0;
    newComentarios = "";
  }

  function deleteRegistro(id) {
    if (confirm("¿Eliminar este registro?")) {
      dbActions.deleteRegistro(id);
      if (editingId === id) resetForm();
    }
  }

  let showEditModal = $state(false);
</script>

<div class="flex flex-col min-h-screen">
  <!-- SECCIÓN SUPERIOR: RESUMEN (Fondo Blanco - Full Width) -->
  <section class="bg-white border-b border-slate-200">
    <div class="max-w-7xl mx-auto px-6 pt-12 pb-10 space-y-10">
      <header
        class="flex flex-col md:flex-row md:items-end justify-between gap-6"
      >
        <div class="space-y-1">
          <p
            class="text-sm font-black tracking-widest uppercase {selectedGrupoId ===
            'g1'
              ? 'text-green-600'
              : 'text-red-500'}"
          >
            Cuentas Familiares / {selectedGrupoId === "g1"
              ? "Ingresos"
              : "Gastos"}
          </p>
          <h2
            class="text-2xl sm:text-4xl font-black text-slate-800 tracking-tight"
          >
            {currentCategoria?.nombre || "Categoría"}
          </h2>
        </div>

        <div
          class="flex gap-3 bg-slate-50 p-2 rounded-2xl border border-slate-200 shadow-sm"
        >
          <Dropdown
            bind:value={selectedGrupoId}
            options={grupoOptions}
            variant={selectedGrupoId === "g1" ? "green" : "red"}
            containerClass="w-56"
          />

          <Dropdown
            bind:value={selectedCategoriaId}
            options={categoriaOptions}
            placeholder="Elegir Categoría"
            containerClass="w-56"
          />
        </div>
      </header>

      <!-- Mini Matrix Resumen -->
      <div
        class="bg-slate-50/50 rounded-[40px] border border-slate-200 overflow-hidden shadow-inner-sm"
      >
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr
                class="text-[10px] font-black text-slate-400 uppercase tracking-widest bg-white/60"
              >
                <th class="px-8 py-5 border-b border-slate-100">Subcategoría</th
                >
                {#each MESES as mes}
                  <th class="px-2 py-5 border-b border-slate-100 text-center"
                    >{mes}</th
                  >
                {/each}
                <th class="px-8 py-5 border-b border-slate-100 text-right"
                  >Anual</th
                >
              </tr>
            </thead>
            <tbody class="text-xs font-bold">
              {#each subcategoriasFiltradas() as sub}
                <tr class="hover:bg-white transition-colors group">
                  <td
                    class="px-8 py-4 border-b border-slate-100/50 text-slate-700"
                    >{sub.nombre}</td
                  >
                  {#each MESES as _, i}
                    {@const value = getTotalSubMes(sub.id, i)}
                    {@const isActive =
                      activeCell?.subId === sub.id && activeCell?.mesIdx === i}
                    <td
                      class="px-2 py-4 border-b border-slate-100/50 text-center transition-all
                      {isActive
                        ? 'bg-indigo-600 text-white shadow-lg relative z-10 rounded-lg font-black'
                        : value > 0
                          ? 'cursor-pointer hover:bg-indigo-50 hover:text-indigo-600'
                          : 'text-slate-400'}"
                      onclick={() => value > 0 && applyCellFilter(sub.id, i)}
                    >
                      {value ? value.toFixed(0) + "€" : "-"}
                    </td>
                  {/each}
                  <td
                    class="px-8 py-4 border-b border-slate-100/50 text-right text-slate-900 text-sm font-black"
                  >
                    {MESES.reduce(
                      (acc, _, i) => acc + getTotalSubMes(sub.id, i),
                      0,
                    ).toFixed(2)}€
                  </td>
                </tr>
              {:else}
                <tr>
                  <td
                    colspan="14"
                    class="px-8 py-10 text-center text-slate-400 italic font-medium"
                    >No hay subcategorías en esta selección.</td
                  >
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>

  <!-- SECCIÓN INFERIOR: REGISTROS (Fondo Gris - Full Width) -->
  <section class="flex-1 bg-slate-50 shadow-inner-lg">
    <div id="form-anchor" class="max-w-7xl mx-auto px-6 py-12 space-y-8">
      <!-- FORMULARIO POR REGISTROS (Alineado y Contenido) -->
      <div
        class="bg-white p-6 rounded-[32px] border border-slate-200 {editingId
          ? 'ring-2 ring-indigo-400 ring-offset-2'
          : ''}"
      >
        <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-end">
          <div class="md:col-span-1">
            <label
              class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
              >Mes</label
            >
            <Dropdown
              bind:value={newMes}
              options={MES_OPTIONS}
              containerClass="h-11"
              labelClass="!py-2 !text-sm"
            />
          </div>
          <div class="md:col-span-2">
            <label
              class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
              >Fecha</label
            >
            <input
              type="date"
              bind:value={newFecha}
              class="w-full h-11 bg-slate-50 border-2 border-slate-100 rounded-2xl px-3 outline-none focus:border-indigo-400 font-black text-sm"
            />
          </div>
          <div class="md:col-span-2">
            <label
              class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
              >Subcategoría</label
            >
            <Dropdown
              bind:value={newSubcategoriaId}
              options={subcategoriaOptions}
              placeholder="Elegir..."
              containerClass="h-11"
              labelClass="!py-2 !text-sm"
            />
          </div>
          <div class="md:col-span-2">
            <label
              class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
              >Concepto</label
            >
            <input
              type="text"
              bind:value={newConcepto}
              placeholder="Descripción..."
              class="w-full h-11 bg-slate-50 border-2 border-slate-100 rounded-2xl px-4 outline-none focus:border-indigo-400 font-bold text-sm"
            />
          </div>
          <div class="md:col-span-1">
            <label
              class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
              >Importe</label
            >
            <div class="relative">
              <input
                type="number"
                step="0.01"
                bind:value={newImporte}
                class="w-full h-11 bg-slate-50 border-2 border-slate-100 rounded-2xl pl-3 pr-7 outline-none focus:border-indigo-400 font-black text-sm {selectedGrupoId ===
                'g1'
                  ? 'text-green-600'
                  : 'text-red-500'}"
              />
              <span
                class="absolute right-2 top-3 text-[10px] font-black text-slate-300"
                >€</span
              >
            </div>
          </div>
          <div class="md:col-span-3">
            <label
              class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
              >Comentarios</label
            >
            <input
              type="text"
              bind:value={newComentarios}
              placeholder="Opcional..."
              class="w-full h-11 bg-slate-50 border-2 border-slate-100 rounded-2xl px-4 outline-none focus:border-indigo-400 font-semibold text-sm"
            />
          </div>
          <div class="md:col-span-1 flex flex-col gap-1">
            <button
              onclick={saveRegistro}
              class="w-full h-11 {selectedGrupoId === 'g1'
                ? 'bg-green-600 hover:bg-green-700'
                : 'bg-red-500 hover:bg-red-600'} text-white font-black text-[10px] rounded-2xl transition-all active:scale-95 whitespace-nowrap shadow-sm"
            >
              {editingId ? "ACTUALIZAR" : "ANOTAR"}
            </button>
            {#if editingId}
              <button
                onclick={resetForm}
                class="w-full text-[9px] font-black text-slate-400 hover:text-slate-600 uppercase"
              >
                Cancelar
              </button>
            {/if}
          </div>
        </div>
      </div>

      <!-- TABLA DE REGISTROS CON FILTROS Y BUSCADOR -->
      <div
        id="records-table-start"
        class="bg-white rounded-[40px] border border-slate-200 shadow-sm overflow-hidden flex flex-col"
      >
        <div
          class="p-6 border-b border-slate-100 flex flex-col lg:flex-row justify-between items-center gap-6"
        >
          <div class="flex flex-wrap items-center gap-3 w-full lg:w-auto">
            <span
              class="text-xs font-black text-slate-400 uppercase tracking-widest mr-2"
              >Filtros:</span
            >

            {#each activeFilters as filter (filter.id)}
              <div
                class="flex items-center gap-2 bg-indigo-50 text-indigo-700 px-3 py-1.5 rounded-xl border border-indigo-100 animate-scale-up"
              >
                <span class="text-[10px] font-black uppercase tracking-tight"
                  >{filter.label}</span
                >
                <button
                  onclick={() => removeFilter(filter.id)}
                  class="text-indigo-300 hover:text-indigo-600 transition-colors font-bold text-xs"
                  >✕</button
                >
              </div>
            {/each}

            <button
              onclick={() => (showFilterModal = true)}
              class="flex items-center gap-2 px-4 py-2 bg-slate-50 hover:bg-slate-100 text-slate-500 rounded-xl border border-slate-200 transition-all text-xs font-bold active:scale-95"
            >
              <span class="text-lg leading-none">+</span> Añadir Filtro
            </button>
          </div>

          <div class="relative w-full lg:w-96">
            <span class="absolute left-4 top-3 text-slate-300">🔍</span>
            <input
              type="text"
              bind:value={globalSearch}
              placeholder="Buscar en registros..."
              class="w-full h-11 bg-slate-50 border-2 border-slate-100 rounded-2xl pl-10 pr-4 outline-none focus:border-indigo-400 text-sm font-bold"
            />
          </div>
        </div>

        <div class="overflow-y-auto max-h-[600px]">
          <table class="w-full text-left border-collapse">
            <thead class="sticky top-0 bg-white z-10 shadow-sm">
              <tr
                class="text-[10px] font-black text-slate-400 uppercase tracking-widest border-b border-slate-100"
              >
                <th
                  class="px-8 py-5 cursor-pointer hover:text-indigo-600 transition-colors w-20"
                  onclick={() => toggleSort("mes")}
                >
                  Mes {sortKey === "mes" ? (sortDir === 1 ? "▲" : "▼") : ""}
                </th>
                <th
                  class="px-8 py-5 cursor-pointer hover:text-indigo-600 transition-colors"
                  onclick={() => toggleSort("fecha")}
                >
                  Fecha {sortKey === "fecha" ? (sortDir === 1 ? "▲" : "▼") : ""}
                </th>
                <th
                  class="px-8 py-5 cursor-pointer hover:text-indigo-600 transition-colors"
                  onclick={() => toggleSort("subcategoria")}
                >
                  Subcategoría {sortKey === "subcategoria"
                    ? sortDir === 1
                      ? "▲"
                      : "▼"
                    : ""}
                </th>
                <th
                  class="px-8 py-5 cursor-pointer hover:text-indigo-600 transition-colors"
                  onclick={() => toggleSort("concepto")}
                >
                  Concepto {sortKey === "concepto"
                    ? sortDir === 1
                      ? "▲"
                      : "▼"
                    : ""}
                </th>
                <th class="px-8 py-5">Comentarios</th>
                <th
                  class="px-8 py-5 cursor-pointer hover:text-indigo-600 transition-colors text-right"
                  onclick={() => toggleSort("importe")}
                >
                  Importe {sortKey === "importe"
                    ? sortDir === 1
                      ? "▲"
                      : "▼"
                    : ""}
                </th>
                <th class="px-8 py-5 w-24"></th>
              </tr>
            </thead>
            <tbody class="text-xs font-bold">
              {#each filteredRecords() as reg (reg.id)}
                <tr
                  class="hover:bg-slate-50 transition-all border-b border-slate-50 group {editingId ===
                  reg.id
                    ? 'bg-indigo-50/50'
                    : ''}"
                >
                  <td class="px-8 py-4 text-slate-400 uppercase"
                    >{MESES[reg.mes]}</td
                  >
                  <td class="px-8 py-4 text-slate-400 whitespace-nowrap"
                    >{reg.fecha || "-"}</td
                  >
                  <td class="px-8 py-4">
                    <span
                      class="bg-indigo-50 text-indigo-700 px-3 py-1.5 rounded-xl text-[10px] font-black uppercase"
                    >
                      {$dbStore.subcategorias.find(
                        (s) => s.id === reg.subcategoriaId,
                      )?.nombre}
                    </span>
                  </td>
                  <td class="px-8 py-4 text-slate-800 font-black text-sm"
                    >{reg.concepto}</td
                  >
                  <td
                    class="px-8 py-4 text-slate-400 italic font-medium truncate max-w-[200px]"
                    >{reg.comentarios || ""}</td
                  >
                  <td
                    class="px-8 py-4 text-right font-black text-base {selectedGrupoId ===
                    'g1'
                      ? 'text-green-600'
                      : 'text-red-500'}"
                  >
                    {reg.importe.toFixed(2)}€
                  </td>
                  <td class="px-8 py-4 text-right">
                    <div
                      class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap"
                    >
                      <button
                        onclick={() => startEdit(reg)}
                        class="p-2 text-slate-300 hover:text-indigo-600 transition-colors"
                        title="Editar"
                      >
                        ✏️
                      </button>
                      <button
                        onclick={() => deleteRegistro(reg.id)}
                        class="p-2 text-slate-300 hover:text-red-500 transition-colors"
                        title="Eliminar"
                      >
                        🗑
                      </button>
                    </div>
                  </td>
                </tr>
              {:else}
                <tr>
                  <td
                    colspan="7"
                    class="px-8 py-24 text-center text-slate-300 font-black text-lg"
                    >No hay registros que coincidan con la búsqueda.</td
                  >
                </tr>
              {/each}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>

  <Modal show={showEditModal} title="Editar Registro" onClose={resetForm}>
    <div class="space-y-6">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
            >Mes</label
          >
          <Dropdown
            bind:value={newMes}
            options={MES_OPTIONS}
            containerClass="h-12"
          />
        </div>
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
            >Fecha</label
          >
          <input
            type="date"
            bind:value={newFecha}
            class="w-full h-12 bg-slate-50 border-2 border-slate-100 rounded-2xl px-4 outline-none focus:border-indigo-400 font-black text-sm"
          />
        </div>
      </div>

      <div>
        <label
          class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
          >Subcategoría</label
        >
        <Dropdown
          bind:value={newSubcategoriaId}
          options={subcategoriaOptions}
          placeholder="Elegir..."
          containerClass="h-12"
        />
      </div>

      <div>
        <label
          class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
          >Concepto</label
        >
        <input
          type="text"
          bind:value={newConcepto}
          placeholder="Descripción..."
          class="w-full h-12 bg-slate-50 border-2 border-slate-100 rounded-2xl px-4 outline-none focus:border-indigo-400 font-bold text-base"
        />
      </div>

      <div class="grid grid-cols-2 gap-4">
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
            >Importe</label
          >
          <div class="relative">
            <input
              type="number"
              step="0.01"
              bind:value={newImporte}
              class="w-full h-12 bg-slate-50 border-2 border-slate-100 rounded-2xl pl-4 pr-10 outline-none focus:border-indigo-400 font-black text-lg {selectedGrupoId ===
              'g1'
                ? 'text-green-600'
                : 'text-red-500'}"
            />
            <span
              class="absolute right-4 top-3 text-sm font-black text-slate-300"
              >€</span
            >
          </div>
        </div>
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-1.5 ml-1"
            >Comentarios</label
          >
          <input
            type="text"
            bind:value={newComentarios}
            placeholder="Opcional..."
            class="w-full h-12 bg-slate-50 border-2 border-slate-100 rounded-2xl px-4 outline-none focus:border-indigo-400 font-semibold text-sm"
          />
        </div>
      </div>

      <div class="flex gap-4 pt-4">
        <button
          onclick={resetForm}
          class="flex-1 bg-slate-100 hover:bg-slate-200 text-slate-600 font-black py-4 rounded-2xl transition-all uppercase tracking-widest text-xs"
        >
          Cancelar
        </button>
        <button
          onclick={saveRegistro}
          class="flex-1 {selectedGrupoId === 'g1'
            ? 'bg-green-600 hover:bg-green-700 shadow-green-100'
            : 'bg-red-500 hover:bg-red-600 shadow-red-100'} text-white font-black py-4 rounded-2xl shadow-xl transition-all active:scale-95 uppercase tracking-widest text-xs"
        >
          Guardar Cambios
        </button>
      </div>
    </div>
  </Modal>

  <Modal
    show={showFilterModal}
    title="Añadir Filtro"
    onClose={() => (showFilterModal = false)}
    maxWidth="max-w-4xl"
  >
    <div class="space-y-8">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1"
            >Seleccionar Columna</label
          >
          <Dropdown
            bind:value={filterCol}
            options={FILTER_COLUMNS}
            containerClass="h-14"
          />
        </div>
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1"
            >Tipo de Operación</label
          >
          <Dropdown
            bind:value={filterOp}
            options={OPERATORS[
              FILTER_COLUMNS.find((c) => c.value === filterCol).type ===
                "string" &&
              FILTER_COLUMNS.find((c) => c.value === filterCol).value ===
                "fecha"
                ? "date"
                : FILTER_COLUMNS.find((c) => c.value === filterCol).type
            ]}
            containerClass="h-14"
          />
        </div>
      </div>

      <div
        class="p-8 bg-slate-50 rounded-[32px] border border-slate-100 space-y-6"
      >
        {#if filterOp === "between"}
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 items-end">
            <div>
              <label
                class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1"
                >Valor Inicial / Desde</label
              >
              {#if filterCol === "fecha"}
                <input
                  type="date"
                  bind:value={filterVal}
                  class="w-full h-14 bg-white border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-black text-lg shadow-sm"
                />
              {:else}
                <input
                  type="number"
                  step="0.01"
                  bind:value={filterVal}
                  class="w-full h-14 bg-white border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-black text-lg shadow-sm"
                />
              {/if}
            </div>
            <div>
              <label
                class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1"
                >Valor Final / Hasta</label
              >
              {#if filterCol === "fecha"}
                <input
                  type="date"
                  bind:value={filterValEnd}
                  class="w-full h-14 bg-white border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-black text-lg shadow-sm"
                />
              {:else}
                <input
                  type="number"
                  step="0.01"
                  bind:value={filterValEnd}
                  class="w-full h-14 bg-white border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-black text-lg shadow-sm"
                />
              {/if}
            </div>
          </div>
        {:else}
          <div>
            <label
              class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1"
              >Valor del Filtro</label
            >
            {#if filterCol === "mes"}
              <Dropdown
                bind:value={filterVal}
                options={MES_OPTIONS}
                containerClass="h-14"
              />
            {:else if filterCol === "subcategoria"}
              <Dropdown
                bind:value={filterVal}
                options={subcategoriaOptions}
                containerClass="h-14"
              />
            {:else if FILTER_COLUMNS.find((c) => c.value === filterCol).type === "number"}
              <input
                type="number"
                step="0.01"
                bind:value={filterVal}
                class="w-full h-14 bg-white border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-black text-lg shadow-sm"
              />
            {:else if filterCol === "fecha"}
              <input
                type="date"
                bind:value={filterVal}
                class="w-full h-14 bg-white border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-black text-lg shadow-sm"
              />
            {:else}
              <input
                type="text"
                bind:value={filterVal}
                placeholder="Introduce el valor a buscar..."
                class="w-full h-14 bg-white border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-bold text-lg shadow-sm"
              />
            {/if}
          </div>
        {/if}
      </div>

      <div class="flex gap-4 pt-4">
        <button
          onclick={() => (showFilterModal = false)}
          class="flex-1 bg-slate-100 hover:bg-slate-200 text-slate-600 font-black py-5 rounded-[24px] transition-all uppercase tracking-widest text-xs"
        >
          Cancelar
        </button>
        <button
          onclick={addFilter}
          class="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white font-black py-5 rounded-[24px] shadow-xl shadow-indigo-100 transition-all active:scale-95 uppercase tracking-widest text-xs"
        >
          Aplicar Filtro Dinámico
        </button>
      </div>
    </div>
  </Modal>
</div>

<style>
  :global(.Dropdown-trigger) {
    height: 100% !important;
  }
  .shadow-inner-sm {
    box-shadow: inset 0 2px 4px 0 rgba(0, 0, 0, 0.05);
  }
  .shadow-inner-lg {
    box-shadow: inset 0 4px 12px 0 rgba(0, 0, 0, 0.03);
  }
</style>

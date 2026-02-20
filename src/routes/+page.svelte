<script>
  import { dbStore } from "$lib/store.svelte.js";

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

  let showSubcategories = $state(false);

  function getSumSubcategoriaMes(subId, mesIdx) {
    return $dbStore.registros
      .filter((r) => r.subcategoriaId === subId && r.mes === mesIdx)
      .reduce((acc, r) => acc + r.importe, 0);
  }

  function getSumCategoriaMes(catId, mesIdx) {
    const subIds = $dbStore.subcategorias
      .filter((s) => s.categoriaId === catId)
      .map((s) => s.id);
    return $dbStore.registros
      .filter((r) => subIds.includes(r.subcategoriaId) && r.mes === mesIdx)
      .reduce((acc, r) => acc + r.importe, 0);
  }

  function getSumGrupoMes(grupoId, mesIdx) {
    const catIds = $dbStore.categorias
      .filter((c) => c.grupoId === grupoId)
      .map((c) => c.id);
    const subIds = $dbStore.subcategorias
      .filter((s) => catIds.includes(s.categoriaId))
      .map((s) => s.id);
    return $dbStore.registros
      .filter((r) => subIds.includes(r.subcategoriaId) && r.mes === mesIdx)
      .reduce((acc, r) => acc + r.importe, 0);
  }

  function getNetoMes(mesIdx) {
    return getSumGrupoMes("g1", mesIdx) - getSumGrupoMes("g2", mesIdx);
  }
</script>

<div class="flex flex-col min-h-screen">
  <!-- CONTENIDO: (Fondo Gris - Full Width) -->
  <section class="flex-1 bg-slate-50 py-12">
    <div class="max-w-7xl mx-auto px-6 space-y-10">
      <div class="flex flex-col md:flex-row justify-between items-center gap-6">
        <h2
          class="text-2xl sm:text-4xl font-black text-slate-800 tracking-tight"
        >
          Resumen de mis cuentas
        </h2>
        <div
          class="flex items-center gap-4 bg-white p-1.5 rounded-2xl border border-slate-200 shadow-sm"
        >
          <span
            class="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-3"
            >Desglose Detallado</span
          >
          <button
            onclick={() => (showSubcategories = !showSubcategories)}
            class="relative inline-flex h-8 w-14 items-center rounded-full transition-colors focus:outline-none {showSubcategories
              ? 'bg-indigo-600'
              : 'bg-slate-300'}"
          >
            <span
              class="inline-block h-5 w-5 transform rounded-full bg-white transition-transform {showSubcategories
                ? 'translate-x-7'
                : 'translate-x-2'}"
            ></span>
          </button>
        </div>
      </div>

      <div
        class="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden"
      >
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr
                class="text-[10px] sm:text-xs font-black text-slate-400 uppercase tracking-widest bg-slate-50"
              >
                <th
                  class="sticky left-0 z-20 bg-slate-50 px-4 sm:px-8 py-3 sm:py-4 border-b border-slate-100 min-w-[120px] sm:min-w-[200px] shadow-[2px_0_5px_rgba(0,0,0,0.05)] sm:shadow-none"
                  >Categoría</th
                >
                {#each MESES as mes}
                  <th
                    class="px-2 sm:px-4 py-3 sm:py-4 border-b border-slate-100 text-center"
                    >{mes}</th
                  >
                {/each}
                <th
                  class="px-4 sm:px-8 py-3 sm:py-4 border-b border-slate-100 text-right"
                  >Total</th
                >
              </tr>
            </thead>
            <tbody class="text-sm font-bold">
              <!-- INGRESOS -->
              <tr class="bg-green-50/50">
                <td
                  colspan="14"
                  class="sticky left-0 z-10 bg-inherit px-4 sm:px-8 py-2 text-[10px] sm:text-xs font-black text-green-700 uppercase tracking-widest shadow-[2px_0_5px_rgba(0,0,0,0.05)] sm:shadow-none"
                  >Ingresos</td
                >
              </tr>
              {#each $dbStore.categorias.filter((c) => c.grupoId === "g1") as cat}
                <tr
                  class="hover:bg-green-50/30 border-b border-slate-50 transition-colors bg-white"
                >
                  <td
                    class="sticky left-0 z-10 bg-inherit px-4 sm:px-8 py-3 sm:py-5 font-bold text-slate-800 text-xs sm:text-base shadow-[2px_0_5px_rgba(0,0,0,0.05)] sm:shadow-none"
                    >{cat.nombre}</td
                  >
                  {#each MESES as _, i}
                    <td
                      class="px-2 sm:px-4 py-3 sm:py-5 text-center text-green-600 text-[10px] sm:text-sm"
                    >
                      {getSumCategoriaMes(cat.id, i).toFixed(0) || "-"}
                    </td>
                  {/each}
                  <td
                    class="px-4 sm:px-8 py-3 sm:py-5 text-right font-black text-green-800 text-xs sm:text-sm"
                  >
                    {MESES.reduce(
                      (acc, _, i) => acc + getSumCategoriaMes(cat.id, i),
                      0,
                    ).toFixed(2)}€
                  </td>
                </tr>
                {#if showSubcategories}
                  {#each $dbStore.subcategorias.filter((s) => s.categoriaId === cat.id) as sub}
                    <tr
                      class="bg-slate-50/30 border-b border-slate-50/50 text-xs"
                    >
                      <td
                        class="sticky left-0 z-10 bg-inherit px-6 sm:px-12 py-2 sm:py-3 text-slate-500 font-medium italic text-[10px] sm:text-xs shadow-[1px_0_3px_rgba(0,0,0,0.03)] sm:shadow-none"
                        >{sub.nombre}</td
                      >
                      {#each MESES as _, i}
                        <td
                          class="px-2 sm:px-4 py-2 sm:py-3 text-center text-slate-400 font-medium text-[9px] sm:text-xs"
                        >
                          {getSumSubcategoriaMes(sub.id, i)
                            ? getSumSubcategoriaMes(sub.id, i).toFixed(0)
                            : "-"}
                        </td>
                      {/each}
                      <td
                        class="px-4 sm:px-8 py-2 sm:py-3 text-right text-slate-500 font-bold text-[9px] sm:text-xs"
                      >
                        {MESES.reduce(
                          (acc, _, i) => acc + getSumSubcategoriaMes(sub.id, i),
                          0,
                        ).toFixed(2)}€
                      </td>
                    </tr>
                  {/each}
                {/if}
              {/each}
              <tr class="bg-green-100/30 font-black border-b border-green-200">
                <td
                  class="sticky left-0 z-10 bg-inherit px-4 sm:px-8 py-4 sm:py-6 text-green-800 text-xs sm:text-base uppercase shadow-[2px_0_5px_rgba(0,0,0,0.05)] sm:shadow-none"
                  >Total Ingresos</td
                >
                {#each MESES as _, i}
                  <td
                    class="px-2 sm:px-4 py-4 sm:py-6 text-center text-green-800 text-sm sm:text-lg"
                  >
                    {getSumGrupoMes("g1", i).toFixed(0)}€
                  </td>
                {/each}
                <td
                  class="px-4 sm:px-8 py-4 sm:py-6 text-right text-green-900 text-lg sm:text-2xl"
                >
                  {MESES.reduce(
                    (acc, _, i) => acc + getSumGrupoMes("g1", i),
                    0,
                  ).toFixed(2)}€
                </td>
              </tr>

              <!-- GASTOS -->
              <tr class="bg-red-50/50">
                <td
                  colspan="14"
                  class="sticky left-0 z-10 bg-inherit px-4 sm:px-8 py-2 text-[10px] sm:text-xs font-black text-red-700 uppercase tracking-widest shadow-[2px_0_5px_rgba(0,0,0,0.05)] sm:shadow-none"
                  >Gastos</td
                >
              </tr>
              {#each $dbStore.categorias.filter((c) => c.grupoId === "g2") as cat}
                <tr
                  class="hover:bg-red-50/30 border-b border-slate-50 transition-colors bg-white"
                >
                  <td
                    class="sticky left-0 z-10 bg-inherit px-4 sm:px-8 py-3 sm:py-5 font-bold text-slate-800 text-xs sm:text-base shadow-[2px_0_5px_rgba(0,0,0,0.05)] sm:shadow-none"
                    >{cat.nombre}</td
                  >
                  {#each MESES as _, i}
                    <td
                      class="px-2 sm:px-4 py-3 sm:py-5 text-center text-red-500 text-[10px] sm:text-sm"
                    >
                      {getSumCategoriaMes(cat.id, i).toFixed(0) || "-"}
                    </td>
                  {/each}
                  <td
                    class="px-4 sm:px-8 py-3 sm:py-5 text-right font-black text-red-800 text-xs sm:text-sm"
                  >
                    {MESES.reduce(
                      (acc, _, i) => acc + getSumCategoriaMes(cat.id, i),
                      0,
                    ).toFixed(2)}€
                  </td>
                </tr>
                {#if showSubcategories}
                  {#each $dbStore.subcategorias.filter((s) => s.categoriaId === cat.id) as sub}
                    <tr
                      class="bg-slate-50/30 border-b border-slate-50/50 text-xs"
                    >
                      <td
                        class="sticky left-0 z-10 bg-inherit px-6 sm:px-12 py-2 sm:py-3 text-slate-500 font-medium italic text-[10px] sm:text-xs shadow-[1px_0_3px_rgba(0,0,0,0.03)] sm:shadow-none"
                        >{sub.nombre}</td
                      >
                      {#each MESES as _, i}
                        <td
                          class="px-2 sm:px-4 py-2 sm:py-3 text-center text-slate-400 font-medium text-[9px] sm:text-xs"
                        >
                          {getSumSubcategoriaMes(sub.id, i)
                            ? getSumSubcategoriaMes(sub.id, i).toFixed(0)
                            : "-"}
                        </td>
                      {/each}
                      <td
                        class="px-4 sm:px-8 py-2 sm:py-3 text-right text-slate-500 font-bold text-[9px] sm:text-xs"
                      >
                        {MESES.reduce(
                          (acc, _, i) => acc + getSumSubcategoriaMes(sub.id, i),
                          0,
                        ).toFixed(2)}€
                      </td>
                    </tr>
                  {/each}
                {/if}
              {/each}
              <tr class="bg-red-100/30 font-black border-b border-red-200">
                <td
                  class="sticky left-0 z-10 bg-inherit px-4 sm:px-8 py-4 sm:py-6 text-red-800 text-xs sm:text-base uppercase shadow-[2px_0_5px_rgba(0,0,0,0.05)] sm:shadow-none"
                  >Total Gastos</td
                >
                {#each MESES as _, i}
                  <td
                    class="px-2 sm:px-4 py-4 sm:py-6 text-center text-red-800 text-sm sm:text-lg"
                  >
                    {getSumGrupoMes("g2", i).toFixed(0)}€
                  </td>
                {/each}
                <td
                  class="px-4 sm:px-8 py-4 sm:py-6 text-right text-red-900 text-lg sm:text-2xl"
                >
                  {MESES.reduce(
                    (acc, _, i) => acc + getSumGrupoMes("g2", i),
                    0,
                  ).toFixed(2)}€
                </td>
              </tr>

              <!-- RESULTADO NETO -->
              <tr class="bg-indigo-600 text-white font-black">
                <td
                  class="sticky left-0 z-10 bg-indigo-600 px-4 sm:px-8 py-6 sm:py-8 text-sm sm:text-lg tracking-tight uppercase shadow-[2px_0_5px_rgba(0,0,0,0.1)] sm:shadow-none"
                  >Resultado Neto</td
                >
                {#each MESES as _, i}
                  <td
                    class="px-2 sm:px-4 py-6 sm:py-8 text-center text-base sm:text-xl"
                  >
                    {getNetoMes(i).toFixed(0)}€
                  </td>
                {/each}
                <td
                  class="px-4 sm:px-8 py-6 sm:py-8 text-right text-xl sm:text-3xl"
                >
                  {MESES.reduce((acc, _, i) => acc + getNetoMes(i), 0).toFixed(
                    2,
                  )}€
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>
</div>

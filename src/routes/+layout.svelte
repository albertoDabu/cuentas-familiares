<script>
  import "../app.css";
  import { feedback, dbActions } from "$lib/store.svelte.js";
  import { page } from "$app/stores";
  import { authState, authActions } from "$lib/auth.svelte.js";
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";

  let { children } = $props();

  const navItems = [
    { href: "/", label: "MIS CUENTAS", icon: "📈" },
    { href: "/gestion", label: "AÑADIR INGRESO/GASTO", icon: "💲" },
    { href: "/configuracion", label: "EDITAR CATEGORIAS", icon: "⚙️" },
  ];

  const authRoutes = ["/login", "/register"];

  $effect(() => {
    if (!authState.loading) {
      const isAuthRoute = authRoutes.includes($page.url.pathname);
      if (!authState.user && !isAuthRoute) {
        goto("/login");
        dbActions.clearData();
      } else if (authState.user && isAuthRoute) {
        goto("/");
        dbActions.refreshData();
      } else if (authState.user) {
        dbActions.refreshData();
      }
    }
  });

  async function handleLogout() {
    await authActions.logout();
    goto("/login");
  }
</script>

<div class="min-h-screen bg-slate-50 flex flex-col font-sans">
  <!-- Top Navigation -->
  <header class="bg-white border-b border-slate-200 sticky top-0 z-10 w-full">
    <div class="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <div
          class="w-8 h-8 bg-indigo-600 rounded-lg flex items-center justify-center text-white font-bold text-xl"
        >
          🏠
        </div>
        <h1 class="text-xl font-black text-slate-800 tracking-tight">
          Presupuesto Familiar
        </h1>
      </div>

      {#if !authState.loading && authState.user && !authRoutes.includes($page.url.pathname)}
        <nav class="flex gap-1">
          {#each navItems as item}
            <a
              href={item.href}
              class="px-4 py-2 rounded-xl text-sm font-bold transition-all {$page
                .url.pathname === item.href
                ? 'bg-indigo-50 text-indigo-700'
                : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700'}"
            >
              <span class="mr-2">{item.icon}</span>
              {item.label}
            </a>
          {/each}
        </nav>

        <div class="flex items-center gap-8">
          <div class="flex items-center gap-3">
            <span
              class="text-[10px] font-black text-slate-400 uppercase tracking-widest"
              >{authState.user.email}</span
            >
            <button
              onclick={handleLogout}
              class="w-10 h-10 flex items-center justify-center bg-slate-50 hover:bg-red-50 text-slate-400 hover:text-red-500 rounded-xl transition-all border border-slate-100"
              title="Cerrar Sesión"
            >
              🚪
            </button>
          </div>

          <div class="w-12 flex justify-end">
            {#if $feedback.saved}
              <div
                class="flex items-center text-green-600 text-sm font-bold animate-fade-in-out"
              >
                <span class="mr-1">✓</span>
              </div>
            {/if}
          </div>
        </div>
      {/if}
    </div>
  </header>

  <main class="flex-1 w-full flex flex-col">
    {#if authState.loading}
      <div class="flex-1 flex items-center justify-center">
        <div
          class="w-8 h-8 border-4 border-indigo-100 border-t-indigo-600 rounded-full animate-spin"
        ></div>
      </div>
    {:else}
      {@render children()}
    {/if}
  </main>
</div>

<style>
  @keyframes fade-in-out {
    0% {
      opacity: 0;
      transform: translateY(5px);
    }
    15% {
      opacity: 1;
      transform: translateY(0);
    }
    85% {
      opacity: 1;
      transform: translateY(0);
    }
    100% {
      opacity: 0;
      transform: translateY(-5px);
    }
  }
  .animate-fade-in-out {
    animation: fade-in-out 2s forwards;
  }
</style>

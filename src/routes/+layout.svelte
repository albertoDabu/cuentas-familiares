<script>
  import "../app.css";
  import { feedback, dbActions } from "$lib/store.svelte.js";
  import { page } from "$app/stores";
  import { authState, authActions } from "$lib/auth.svelte.js";
  import { onMount } from "svelte";
  import { goto } from "$app/navigation";
  import Modal from "$lib/components/Modal.svelte";
  import Toast from "$lib/components/Toast.svelte";

  let { children } = $props();
  let showMobileWarning = $state(false);

  const navItems = [
    { href: "/", label: "MIS CUENTAS", icon: "📈", mobile: "CUENTAS" },
    {
      href: "/gestion",
      label: "ANOTAR INGRESOS Y GASTOS",
      icon: "💲",
      mobile: "ANOTAR",
    },
    {
      href: "/configuracion",
      label: "EDITAR CATEGORIAS",
      icon: "⚙️",
      mobile: "CATEGORIAS",
    },
  ];

  const authRoutes = ["/login", "/register"];

  $effect(() => {
    if (!authState.loading) {
      const mode = $page.url.searchParams.get("mode");
      if (mode === "test" && !authState.user) {
        authActions.login("usuario@test.com", "test");
        return;
      }

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

  onMount(() => {
    if (window.innerWidth < 768) {
      showMobileWarning = true;
    }
  });
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
        <h1
          class="hidden md:block text-xl font-black text-slate-800 tracking-tight"
        >
          CUENTAS FAMILIARES
        </h1>
      </div>

      {#if !authState.loading && authState.user && !authRoutes.includes($page.url.pathname)}
        <nav class="flex gap-0.5 sm:gap-1">
          {#each navItems as item}
            <a
              href={item.href}
              class="px-2 sm:px-4 py-2 rounded-xl text-[10px] sm:text-sm font-bold transition-all {$page
                .url.pathname === item.href
                ? 'bg-indigo-50 text-indigo-700'
                : 'text-slate-500 hover:bg-slate-50 hover:text-slate-700'}"
            >
              <span class="mr-1 sm:mr-2">{item.icon}</span>
              <span class="hidden sm:inline">{item.label}</span>
              <span class="inline sm:hidden">
                {item.mobile}
              </span>
            </a>
          {/each}
        </nav>

        <div class="flex items-center gap-2 sm:gap-8">
          <div class="flex items-center gap-2 sm:gap-3">
            <span
              class="hidden sm:inline text-[10px] font-black text-slate-400 uppercase tracking-widest"
              >{authState.user.email}</span
            >
            <button
              onclick={handleLogout}
              class="w-8 h-8 sm:w-10 sm:h-10 flex items-center justify-center bg-slate-50 hover:bg-red-50 text-slate-400 hover:text-red-500 rounded-xl transition-all border border-slate-100"
              title="Cerrar Sesión"
            >
              ➜]
            </button>
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

  <!-- Mobile Warning Modal -->
  <Modal
    show={showMobileWarning}
    title="Optimización de Pantalla"
    onClose={() => (showMobileWarning = false)}
  >
    <div class="space-y-6">
      <div class="flex flex-col items-center text-center gap-4">
        <div class="text-5xl">💻</div>
        <p class="text-slate-600 text-lg font-medium leading-relaxed">
          Se recomienda usar esta aplicación desde un <span
            class="text-indigo-600 font-bold">ordenador</span
          > para mejorar la experiencia de uso y visualización de datos.
        </p>
      </div>

      <button
        onclick={() => (showMobileWarning = false)}
        class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-black py-4 rounded-2xl shadow-xl shadow-indigo-100 transition-all active:scale-95 uppercase tracking-widest text-xs"
      >
        Entendido
      </button>
    </div>
  </Modal>

  <Toast />
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

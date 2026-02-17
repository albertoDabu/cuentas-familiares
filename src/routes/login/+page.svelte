<script>
  import { supabase } from "$lib/supabaseClient";
  import { goto } from "$app/navigation";

  let email = $state("");
  let password = $state("");
  let loading = $state(false);
  let error = $state(null);

  async function handleLogin() {
    loading = true;
    error = null;
    const { error: authError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (authError) {
      error = authError.message;
      loading = false;
    } else {
      goto("/");
    }
  }
</script>

<div class="min-h-[80vh] flex items-center justify-center px-6">
  <div
    class="w-full max-w-md bg-white rounded-[40px] border border-slate-200 shadow-2xl p-10 space-y-8 animate-scale-up"
  >
    <div class="text-center space-y-2">
      <div
        class="w-16 h-16 bg-indigo-600 rounded-2xl flex items-center justify-center text-white text-3xl font-bold mx-auto shadow-xl shadow-indigo-100 mb-4"
      >
        🏠
      </div>
      <h2 class="text-3xl font-black text-slate-800 tracking-tight">
        Bienvenido
      </h2>
      <p class="text-slate-400 font-bold text-sm uppercase tracking-widest">
        Inicia sesión en tus Cuentas
      </p>
    </div>

    <form
      onsubmit={(e) => {
        e.preventDefault();
        handleLogin();
      }}
      class="space-y-6"
    >
      {#if error}
        <div
          class="bg-red-50 text-red-500 p-4 rounded-2xl text-xs font-black uppercase tracking-wider border border-red-100"
        >
          {error}
        </div>
      {/if}

      <div class="space-y-4">
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1"
            >Email</label
          >
          <input
            type="email"
            bind:value={email}
            required
            placeholder="tu@email.com"
            class="w-full h-14 bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-bold text-lg transition-all"
          />
        </div>
        <div>
          <label
            class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1"
            >Contraseña</label
          >
          <input
            type="password"
            bind:value={password}
            required
            placeholder="••••••••"
            class="w-full h-14 bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 outline-none focus:border-indigo-400 font-bold text-lg transition-all"
          />
        </div>
      </div>

      <button
        type="submit"
        disabled={loading}
        class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-black py-5 rounded-[24px] shadow-xl shadow-indigo-100 transition-all active:scale-95 uppercase tracking-widest text-xs disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {loading ? "Iniciando..." : "Entrar ahora"}
      </button>
    </form>

    <div class="text-center pt-4">
      <p class="text-slate-400 text-sm font-bold">
        ¿No tienes cuenta?
        <a
          href="/register"
          class="text-indigo-600 hover:text-indigo-800 ml-1 transition-colors"
          >Regístrate</a
        >
      </p>
    </div>
  </div>
</div>

<style>
  @keyframes scale-up {
    from {
      opacity: 0;
      transform: scale(0.95);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
  .animate-scale-up {
    animation: scale-up 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  }
</style>

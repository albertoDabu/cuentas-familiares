<script>
  let {
    show = false,
    title = "",
    onClose,
    children,
    maxWidth = "max-w-2xl",
  } = $props();

  function handleBackdropClick() {
    if (onClose) onClose();
  }

  function handleKeydown(e) {
    if (e.key === "Escape" && show && onClose) {
      onClose();
    }
  }
</script>

<svelte:window onkeydown={handleKeydown} />

{#if show}
  <div class="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
    <!-- Backdrop -->
    <button
      onclick={handleBackdropClick}
      class="absolute inset-0 bg-slate-900/40 backdrop-blur-sm cursor-default w-full h-full border-none shadow-none"
      aria-label="Cerrar modal"
    ></button>

    <!-- Content -->
    <div
      class="relative bg-white w-full {maxWidth} rounded-[40px] shadow-2xl p-8 sm:p-10 space-y-8 animate-scale-up border border-slate-100"
    >
      {#if title}
        <div class="space-y-2">
          <h3 class="text-3xl font-black text-slate-800 tracking-tight">
            {title}
          </h3>
          <div class="h-1.5 w-12 bg-indigo-500 rounded-full"></div>
        </div>
      {/if}

      <div class="max-h-[70vh] overflow-y-auto pr-2 custom-scrollbar">
        {@render children()}
      </div>

      <button
        onclick={onClose}
        class="absolute top-8 right-8 text-slate-300 hover:text-slate-500 transition-colors text-2xl font-bold"
        aria-label="Cerrar"
      >
        ✕
      </button>
    </div>
  </div>
{/if}

<style>
  @keyframes scale-up {
    from {
      opacity: 0;
      transform: scale(0.95) translateY(10px);
    }
    to {
      opacity: 1;
      transform: scale(1) translateY(0);
    }
  }
  .animate-scale-up {
    animation: scale-up 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  }

  .custom-scrollbar::-webkit-scrollbar {
    width: 6px;
  }
  .custom-scrollbar::-webkit-scrollbar-track {
    background: transparent;
  }
  .custom-scrollbar::-webkit-scrollbar-thumb {
    background: #e2e8f0;
    border-radius: 10px;
  }
  .custom-scrollbar::-webkit-scrollbar-thumb:hover {
    background: #cbd5e1;
  }
</style>

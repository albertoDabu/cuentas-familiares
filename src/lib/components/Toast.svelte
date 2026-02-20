<script>
  import { feedback } from "$lib/store.svelte.js";
  import { fade, fly } from "svelte/transition";
  import { backOut } from "svelte/easing";

  let show = $derived($feedback.show);
  let message = $derived($feedback.message);
  let type = $derived($feedback.type);

  const icons = {
    success: "✓",
    error: "✕",
    info: "ℹ",
  };

  const colors = {
    success: "bg-green-600 shadow-green-100",
    error: "bg-red-600 shadow-red-100",
    info: "bg-indigo-600 shadow-indigo-100",
  };
</script>

{#if show}
  <div
    transition:fly={{ y: 20, duration: 400, easing: backOut }}
    class="fixed bottom-8 left-1/2 -translate-x-1/2 z-100 flex items-center gap-3 px-6 py-4 rounded-2xl text-white font-black shadow-2xl {colors[
      type
    ]}"
  >
    <div
      class="w-6 h-6 flex items-center justify-center bg-white/20 rounded-lg text-lg"
    >
      {icons[type]}
    </div>
    <p class="text-sm tracking-tight uppercase">
      {message}
    </p>
  </div>
{/if}

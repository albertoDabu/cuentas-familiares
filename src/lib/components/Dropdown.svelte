<script>
  import { onMount } from "svelte";

  let {
    value = $bindable(),
    options = [],
    placeholder = "Seleccionar...",
    labelClass = "",
    containerClass = "",
    variant = "default", // 'default', 'green', 'red'
  } = $props();

  let isOpen = $state(false);
  let container;

  const selectedOption = $derived(options.find((o) => o.value === value));

  function toggle() {
    isOpen = !isOpen;
  }

  function select(val) {
    value = val;
    isOpen = false;
  }

  // Close on outside click
  onMount(() => {
    function handleClickOutside(event) {
      if (container && !container.contains(event.target)) {
        isOpen = false;
      }
    }

    document.addEventListener("click", handleClickOutside);
    return () => document.removeEventListener("click", handleClickOutside);
  });

  const variants = {
    default: "border-slate-100 text-slate-700 bg-white hover:border-slate-300",
    green:
      "border-green-100 text-green-700 bg-green-50/30 hover:border-green-300",
    red: "border-red-100 text-red-700 bg-red-50/30 hover:border-red-300",
  };
</script>

<div class="relative {containerClass}" bind:this={container}>
  <button
    type="button"
    onclick={toggle}
    class="w-full flex items-center justify-between px-4 py-2.5 border-2 rounded-xl font-bold transition-all focus:outline-none focus:ring-2 ring-indigo-100 {variants[
      variant
    ]} {labelClass}"
  >
    <span>{selectedOption ? selectedOption.label : placeholder}</span>
    <span
      class="ml-2 transition-transform duration-200 {isOpen
        ? 'rotate-180'
        : ''}"
    >
      <svg
        class="w-4 h-4"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="3"
          d="M19 9l-7 7-7-7"
        />
      </svg>
    </span>
  </button>

  {#if isOpen}
    <div
      class="absolute z-50 mt-2 w-full bg-white border border-slate-200 rounded-2xl shadow-2xl py-2 overflow-hidden animate-slide-down"
    >
      <div class="max-h-60 overflow-y-auto">
        {#each options as option}
          <button
            type="button"
            onclick={() => select(option.value)}
            class="w-full text-left px-4 py-3 text-sm font-semibold transition-colors
            {value === option.value
              ? 'bg-indigo-50 text-indigo-700'
              : 'text-slate-600 hover:bg-slate-50'}"
          >
            {option.label}
          </button>
        {/each}
        {#if options.length === 0}
          <div class="px-4 py-3 text-sm text-slate-400 italic">
            Sin opciones
          </div>
        {/if}
      </div>
    </div>
  {/if}
</div>

<style>
  @keyframes slide-down {
    from {
      opacity: 0;
      transform: translateY(-10px) scale(0.95);
    }
    to {
      opacity: 1;
      transform: translateY(0) scale(1);
    }
  }
  .animate-slide-down {
    animation: slide-down 0.15s cubic-bezier(0.16, 1, 0.3, 1);
  }
</style>

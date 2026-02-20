import { supabase } from "./supabaseClient";

export const authState = $state({
    /** @type {import('@supabase/supabase-js').User | null} */
    user: null,
    /** @type {import('@supabase/supabase-js').Session | null} */
    session: null,
    loading: true
});

supabase.auth.onAuthStateChange((event, session) => {
    authState.user = session?.user ?? null;
    authState.session = session;
    authState.loading = false;
});

export const authActions = {
    /**
     * @param {string} email
     * @param {string} password
     */
    login: async (email, password) => {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) console.error("Error en auto-login:", error.message);
    },
    logout: async () => {
        await supabase.auth.signOut();
    }
};

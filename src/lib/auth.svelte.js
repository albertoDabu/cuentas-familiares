import { supabase } from "./supabaseClient";

export const authState = $state({
    user: null,
    session: null,
    loading: true
});

supabase.auth.onAuthStateChange((event, session) => {
    authState.user = session?.user ?? null;
    authState.session = session;
    authState.loading = false;
});

export const authActions = {
    logout: async () => {
        await supabase.auth.signOut();
    }
};

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { UserWithDetails, InviteUserRequest, UpdateUserRequest, TenantAuthSettings } from './types';
import { toast } from 'sonner';

const API_BASE = '/api/settings';

// --- Users Hook ---

export function useUsers() {
    return useQuery<UserWithDetails[]>({
        queryKey: ['settings', 'users'],
        queryFn: async () => {
            const res = await fetch(`${API_BASE}/users`);
            if (!res.ok) throw new Error('Failed to fetch users');
            return res.json();
        },
    });
}

export function useInviteUser() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async (data: InviteUserRequest) => {
            const res = await fetch(`${API_BASE}/users`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data),
            });
            if (!res.ok) {
                const error = await res.json();
                throw new Error(error.error || 'Failed to invite user');
            }
            return res.json();
        },
        onSuccess: () => {
            toast.success('User invited successfully');
            queryClient.invalidateQueries({ queryKey: ['settings', 'users'] });
        },
        onError: (error: Error) => {
            toast.error(error.message);
        },
    });
}

export function useUpdateUser() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async ({ id, data }: { id: string; data: UpdateUserRequest }) => {
            const res = await fetch(`${API_BASE}/users/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data),
            });
            if (!res.ok) {
                const error = await res.json();
                throw new Error(error.error || 'Failed to update user');
            }
            return res.json();
        },
        onSuccess: () => {
            toast.success('User updated successfully');
            queryClient.invalidateQueries({ queryKey: ['settings', 'users'] });
        },
        onError: (error: Error) => {
            toast.error(error.message);
        },
    });
}

// --- Auth Settings Hook ---

export function useAuthSettings() {
    return useQuery<TenantAuthSettings>({
        queryKey: ['settings', 'auth'],
        queryFn: async () => {
            const res = await fetch(`${API_BASE}/tenant/auth`);
            if (!res.ok) throw new Error('Failed to fetch auth settings');
            return res.json();
        },
    });
}

export function useUpdateAuthSettings() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: async (data: Partial<TenantAuthSettings>) => {
            const res = await fetch(`${API_BASE}/tenant/auth`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data),
            });
            if (!res.ok) {
                const error = await res.json();
                throw new Error(error.error || 'Failed to update settings');
            }
            return res.json();
        },
        onSuccess: () => {
            toast.success('Settings updated successfully');
            queryClient.invalidateQueries({ queryKey: ['settings', 'auth'] });
        },
        onError: (error: Error) => {
            toast.error(error.message);
        },
    });
}

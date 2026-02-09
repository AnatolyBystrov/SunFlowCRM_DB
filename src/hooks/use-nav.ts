import { useMemo } from 'react';
import type { NavItem } from '@/types';
import { useAuth } from './use-auth';

/**
 * Hook to filter navigation items based on current user permissions/roles
 */
export function useFilteredNavItems(items: NavItem[]) {
  const { roles, tenantId, authenticated, loading } = useAuth();

  const filteredItems = useMemo(() => {
    if (loading) return []; // Or return empty, or full list depending on UX preference. Empty is safer.

    const filterItem = (item: NavItem): NavItem | null => {
      // Check access conditions
      if (item.access) {
        // 1. Check Role
        if (item.access.role) {
          if (!authenticated || !roles.includes(item.access.role)) {
            return null;
          }
        }

        // 2. Check Organization Requirement
        if (item.access.requireOrg) {
          if (!tenantId) {
            return null;
          }
        }

        // Future: Check plan, features, permissions
      }

      // Check children
      if (item.items && item.items.length > 0) {
        const filteredChildren = item.items
          .map(filterItem)
          .filter((child): child is NavItem => child !== null);

        // If it was a group that now has no children, maybe hide it? 
        // For now, we keep it if it has a URL itself or if we want to show empty groups.
        // Usually, if a parent has no visible children and no URL, we hide it.
        if (filteredChildren.length === 0 && item.url === '#') {
          return null;
        }

        return { ...item, items: filteredChildren };
      }

      return item;
    };

    return items
      .map(filterItem)
      .filter((item): item is NavItem => item !== null);
  }, [items, roles, tenantId, authenticated, loading]);

  return filteredItems;
}

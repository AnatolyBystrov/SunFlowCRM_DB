'use client';

import { GalleryVerticalEnd } from 'lucide-react';
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar
} from '@/components/ui/sidebar';

/**
 * Organization Switcher - Placeholder
 * 
 * Note: Clerk Organizations feature is not available in SuperTokens by default.
 * This component is a placeholder. To implement multi-tenancy:
 * 1. Create a custom organizations table in your database
 * 2. Implement organization management API endpoints
 * 3. Store organization ID in SuperTokens session claims
 * 4. Update this component to fetch and switch between organizations
 */
export function OrgSwitcher() {
  const { state } = useSidebar();

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <SidebarMenuButton size='lg' disabled>
          <div className='bg-sidebar-primary text-sidebar-primary-foreground flex aspect-square size-8 shrink-0 items-center justify-center rounded-lg'>
            <GalleryVerticalEnd className='size-4' />
          </div>
          <div
            className={`grid flex-1 text-left text-sm leading-tight transition-all duration-200 ease-in-out ${state === 'collapsed'
                ? 'invisible max-w-0 overflow-hidden opacity-0'
                : 'visible max-w-full opacity-100'
              }`}
          >
            <span className='truncate font-medium'>My Workspace</span>
            <span className='text-muted-foreground truncate text-xs'>
              Personal
            </span>
          </div>
        </SidebarMenuButton>
      </SidebarMenuItem>
    </SidebarMenu>
  );
}

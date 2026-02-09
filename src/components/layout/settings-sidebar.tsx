'use client';

import {
    Sidebar,
    SidebarContent,
    SidebarGroup,
    SidebarGroupContent,
    SidebarGroupLabel,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from '@/components/ui/sidebar';
import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { User, Settings, Shield, Users } from 'lucide-react';
import { useAuth } from '@/hooks/use-auth';
import { Separator } from '@/components/ui/separator';

export function SettingsSidebar() {
    const pathname = usePathname();
    const { isAdmin, loading } = useAuth();

    return (
        <Sidebar collapsible="none" className="w-64 border-r bg-background">
            <SidebarHeader className="h-16 border-b flex items-start justify-center px-6">
                <h2 className="text-lg font-semibold tracking-tight">Settings</h2>
            </SidebarHeader>
            <SidebarContent>
                {/* Personal Settings */}
                <SidebarGroup>
                    <SidebarGroupLabel>Personal</SidebarGroupLabel>
                    <SidebarGroupContent>
                        <SidebarMenu>
                            <SidebarMenuItem>
                                <SidebarMenuButton asChild isActive={pathname === '/settings/profile'}>
                                    <Link href="/settings/profile">
                                        <User />
                                        <span>Profile</span>
                                    </Link>
                                </SidebarMenuButton>
                            </SidebarMenuItem>
                        </SidebarMenu>
                    </SidebarGroupContent>
                </SidebarGroup>

                <Separator className="mx-4 w-auto opacity-50" />

                {/* Organization Settings - Admin Only */}
                {!loading && isAdmin() && (
                    <SidebarGroup>
                        <SidebarGroupLabel>Organization</SidebarGroupLabel>
                        <SidebarGroupContent>
                            <SidebarMenu>
                                <SidebarMenuItem>
                                    <SidebarMenuButton asChild isActive={pathname === '/settings/organization' || pathname === '/settings/organization/users'}>
                                        <Link href="/settings/organization/users">
                                            <Users />
                                            <span>Users & Roles</span>
                                        </Link>
                                    </SidebarMenuButton>
                                </SidebarMenuItem>
                                <SidebarMenuItem>
                                    <SidebarMenuButton asChild isActive={pathname === '/settings/organization/auth'}>
                                        <Link href="/settings/organization/auth">
                                            <Shield />
                                            <span>Auth & Security</span>
                                        </Link>
                                    </SidebarMenuButton>
                                </SidebarMenuItem>
                            </SidebarMenu>
                        </SidebarGroupContent>
                    </SidebarGroup>
                )}
            </SidebarContent>
        </Sidebar>
    );
}

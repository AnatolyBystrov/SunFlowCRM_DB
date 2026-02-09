'use client';
import { useTheme } from 'next-themes';
import React, { useState } from 'react';
import { ActiveThemeProvider } from '../themes/active-theme';
import { SuperTokensProvider } from '../auth/supertokens-provider';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

export default function Providers({
  activeThemeValue,
  children
}: {
  activeThemeValue: string;
  children: React.ReactNode;
}) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1 minute
        refetchOnWindowFocus: false,
      },
    },
  }));

  return (
    <>
      <ActiveThemeProvider initialTheme={activeThemeValue}>
        <SuperTokensProvider>
          <QueryClientProvider client={queryClient}>
            {children}
          </QueryClientProvider>
        </SuperTokensProvider>
      </ActiveThemeProvider>
    </>
  );
}


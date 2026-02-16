'use client';

import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { IconX } from '@tabler/icons-react';

interface BulkAction {
  label: string;
  icon: React.ComponentType<{ className?: string }>;
  onClick: () => void;
  variant?: 'default' | 'destructive' | 'outline' | 'secondary';
  disabled?: boolean;
}

interface BulkActionBarProps {
  selectedCount: number;
  onClearSelection: () => void;
  actions: BulkAction[];
}

/**
 * Bulk Action Bar - Appears when rows are selected
 *
 * Best Practice (Pipedrive pattern):
 * - Fixed position bar with actions
 * - Shows count of selected items
 * - Quick clear selection
 * - Actions contextual to entity type
 */
export function BulkActionBar({
  selectedCount,
  onClearSelection,
  actions
}: BulkActionBarProps) {
  return (
    <Card className='border-primary/30 bg-primary/5 flex items-center justify-between gap-4 p-3'>
      <div className='flex items-center gap-4'>
        <span className='text-sm font-semibold'>
          {selectedCount} {selectedCount === 1 ? 'item' : 'items'} selected
        </span>

        <div className='flex flex-wrap items-center gap-2'>
          {actions.map((action, idx) => {
            const Icon = action.icon;
            return (
              <Button
                key={idx}
                size='sm'
                variant={action.variant || 'outline'}
                onClick={action.onClick}
                disabled={action.disabled}
              >
                <Icon className='mr-2 h-4 w-4' />
                {action.label}
              </Button>
            );
          })}
        </div>
      </div>

      <Button size='sm' variant='ghost' onClick={onClearSelection}>
        <IconX className='mr-2 h-4 w-4' />
        Clear
      </Button>
    </Card>
  );
}

'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { IconPlus, IconCheck, IconTrash } from '@tabler/icons-react';
import { ActivitiesTable } from '@/features/crm/activities/components/activities-table';
import { ActivityFormDialog } from '@/features/crm/activities/components/activity-form-dialog';
import { BulkActionBar } from '@/features/crm/components/bulk-action-bar';
import {
  useActivities,
  useToggleActivityDone
} from '@/features/crm/activities/hooks/use-activities';
import type {
  PaginationState,
  SortingState,
  RowSelectionState
} from '@tanstack/react-table';
import type { ActivityType } from '@prisma/client';
import { toast } from 'sonner';

/**
 * Activities Page
 * Best Practice (Context7): Server-side filtering with React Query + tabbed interface
 */
export default function ActivitiesPage() {
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [typeFilter, setTypeFilter] = useState<ActivityType | 'ALL'>('ALL');
  const [doneTab, setDoneTab] = useState<'pending' | 'completed'>('pending');
  const [pagination, setPagination] = useState<PaginationState>({
    pageIndex: 0,
    pageSize: 10
  });
  const [sorting, setSorting] = useState<SortingState>([]);
  const [bulkSelection, setBulkSelection] = useState<RowSelectionState>({});

  const { data, isLoading, error } = useActivities({
    type: typeFilter === 'ALL' ? undefined : typeFilter,
    done: doneTab === 'completed',
    skip: pagination.pageIndex * pagination.pageSize,
    take: pagination.pageSize
  });

  const toggleDone = useToggleActivityDone();

  const activities = data?.activities || [];
  const total = data?.total || 0;
  const pageCount = Math.ceil(total / pagination.pageSize);

  const handleToggleDone = async (id: string, done: boolean) => {
    await toggleDone.mutateAsync({ id, done });
  };

  // Get selected activities
  const selectedActivityIds = Object.keys(bulkSelection).filter(
    (key) => bulkSelection[key]
  );
  const selectedActivities = activities.filter((activity) =>
    selectedActivityIds.includes(activity.id)
  );

  // Bulk action handlers
  const handleBulkMarkDone = async () => {
    // TODO: Implement API call for bulk mark done
    toast.promise(
      Promise.resolve(), // Replace with actual API call
      {
        loading: `Marking ${selectedActivities.length} activities as done...`,
        success: `${selectedActivities.length} activities completed`,
        error: 'Failed to mark activities as done'
      }
    );
    setBulkSelection({});
  };

  const handleBulkDelete = async () => {
    // TODO: Implement API call for bulk delete
    toast.promise(
      Promise.resolve(), // Replace with actual API call
      {
        loading: `Deleting ${selectedActivities.length} activities...`,
        success: `${selectedActivities.length} activities deleted`,
        error: 'Failed to delete activities'
      }
    );
    setBulkSelection({});
  };

  return (
    <div className='flex-1 space-y-4 p-4 pt-6 md:p-8'>
      <div className='flex items-center justify-between'>
        <div>
          <h2 className='text-3xl font-bold tracking-tight'>Activities</h2>
          <p className='text-muted-foreground'>
            Manage calls, meetings, tasks, and emails
          </p>
        </div>
        <Button onClick={() => setCreateDialogOpen(true)}>
          <IconPlus className='mr-2 h-4 w-4' />
          New Activity
        </Button>
      </div>

      {/* Bulk Action Bar */}
      {selectedActivities.length > 0 && (
        <BulkActionBar
          selectedCount={selectedActivities.length}
          onClearSelection={() => setBulkSelection({})}
          actions={[
            {
              label: 'Mark Done',
              icon: IconCheck,
              onClick: handleBulkMarkDone,
              variant: 'default'
            },
            {
              label: 'Delete',
              icon: IconTrash,
              onClick: handleBulkDelete,
              variant: 'destructive'
            }
          ]}
        />
      )}

      <Card>
        <CardHeader>
          <div className='flex items-center justify-between'>
            <div>
              <CardTitle>All Activities</CardTitle>
              <CardDescription>
                Track and manage your scheduled activities
              </CardDescription>
            </div>
            <Select
              value={typeFilter}
              onValueChange={(value) => {
                setTypeFilter(value as ActivityType | 'ALL');
                setPagination({ ...pagination, pageIndex: 0 });
              }}
            >
              <SelectTrigger className='w-[180px]'>
                <SelectValue placeholder='Filter by type' />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value='ALL'>All Types</SelectItem>
                <SelectItem value='CALL'>Calls</SelectItem>
                <SelectItem value='EMAIL'>Emails</SelectItem>
                <SelectItem value='MEETING'>Meetings</SelectItem>
                <SelectItem value='TASK'>Tasks</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent>
          <Tabs
            value={doneTab}
            onValueChange={(v) => {
              setDoneTab(v as 'pending' | 'completed');
              setPagination((prev) => ({ ...prev, pageIndex: 0 }));
            }}
          >
            <TabsList className='mb-4'>
              <TabsTrigger value='pending'>Pending</TabsTrigger>
              <TabsTrigger value='completed'>Completed</TabsTrigger>
            </TabsList>
          </Tabs>

          {error ? (
            <div className='text-destructive py-12 text-center'>
              {error instanceof Error
                ? error.message
                : 'Failed to load activities'}
            </div>
          ) : !isLoading && activities.length === 0 ? (
            <div className='flex flex-col items-center justify-center py-16 text-center'>
              <IconPlus className='text-muted-foreground/50 mb-4 h-12 w-12' />
              <h3 className='text-lg font-semibold'>
                {doneTab === 'pending'
                  ? 'No pending activities'
                  : 'No completed activities'}
              </h3>
              <p className='text-muted-foreground mt-1 max-w-sm text-sm'>
                {doneTab === 'pending'
                  ? 'Schedule calls, meetings, and tasks to stay on track.'
                  : 'Completed activities will appear here.'}
              </p>
              {doneTab === 'pending' && (
                <Button
                  className='mt-4'
                  onClick={() => setCreateDialogOpen(true)}
                >
                  <IconPlus className='mr-2 h-4 w-4' />
                  New Activity
                </Button>
              )}
            </div>
          ) : (
            <ActivitiesTable
              data={activities}
              pageCount={pageCount}
              pagination={pagination}
              onPaginationChange={setPagination}
              sorting={sorting}
              onSortingChange={setSorting}
              isLoading={isLoading}
              onToggleDone={handleToggleDone}
              enableBulkSelection={true}
              bulkSelection={bulkSelection}
              onBulkSelectionChange={setBulkSelection}
            />
          )}
        </CardContent>
      </Card>

      <ActivityFormDialog
        open={createDialogOpen}
        onOpenChange={setCreateDialogOpen}
      />
    </div>
  );
}

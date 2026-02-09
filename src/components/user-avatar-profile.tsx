import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';

interface UserAvatarProfileProps {
  className?: string;
  showInfo?: boolean;
  user: {
    imageUrl?: string;
    name?: string | null;
    email: string;
  } | null;
}

export function UserAvatarProfile({
  className,
  showInfo = false,
  user
}: UserAvatarProfileProps) {
  const initials = user?.name?.slice(0, 2)?.toUpperCase() || user?.email?.slice(0, 2)?.toUpperCase() || 'CN';

  return (
    <div className='flex items-center gap-2'>
      <Avatar className={className}>
        <AvatarImage src={user?.imageUrl || ''} alt={user?.name || user?.email || ''} />
        <AvatarFallback className='rounded-lg'>
          {initials}
        </AvatarFallback>
      </Avatar>

      {showInfo && (
        <div className='grid flex-1 text-left text-sm leading-tight'>
          <span className='truncate font-semibold'>{user?.name || user?.email || ''}</span>
          <span className='truncate text-xs'>
            {user?.email || ''}
          </span>
        </div>
      )}
    </div>
  );
}

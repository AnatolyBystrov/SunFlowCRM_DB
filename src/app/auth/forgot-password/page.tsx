import { buttonVariants } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { IconStar } from '@tabler/icons-react';
import { GitHubLogoIcon } from '@radix-ui/react-icons';
import { Metadata } from 'next';
import Link from 'next/link';
import { InteractiveGridPattern } from '@/features/auth/components/interactive-grid';
import { ForgotPasswordForm } from '@/features/auth/components/forgot-password-form';

export const metadata: Metadata = {
    title: 'Forgot Password',
    description: 'Reset your password'
};

async function getGithubStars() {
    try {
        const response = await fetch(
            'https://api.github.com/repos/kiranism/next-shadcn-dashboard-starter',
            {
                headers: {
                    Accept: 'application/vnd.github+json'
                },
                next: {
                    revalidate: 3600
                }
            }
        );

        if (!response.ok) {
            return 5914; // fallback
        }

        const data = await response.json();
        return data.stargazers_count || 5914;
    } catch (error) {
        return 5914; // fallback
    }
}

export default async function ForgotPasswordPage() {
    const stars = await getGithubStars();

    return (
        <div className='relative h-screen flex-col items-center justify-center md:grid lg:max-w-none lg:grid-cols-2 lg:px-0'>
            <Link
                href='/auth/sign-in'
                className={cn(
                    buttonVariants({ variant: 'ghost' }),
                    'absolute top-4 right-4 md:top-8 md:right-8'
                )}
            >
                Sign In
            </Link>
            <div className='bg-muted relative hidden h-full flex-col p-10 text-white lg:flex dark:border-r'>
                <div className='absolute inset-0 bg-zinc-900' />
                <div className='relative z-20 flex items-center text-lg font-medium'>
                    <svg
                        xmlns='http://www.w3.org/2000/svg'
                        viewBox='0 0 24 24'
                        fill='none'
                        stroke='currentColor'
                        strokeWidth='2'
                        strokeLinecap='round'
                        strokeLinejoin='round'
                        className='mr-2 h-6 w-6'
                    >
                        <path d='M15 6v12a3 3 0 1 0 3-3H6a3 3 0 1 0 3 3V6a3 3 0 1 0-3 3h12a3 3 0 1 0-3-3' />
                    </svg>
                    Logo
                </div>
                <InteractiveGridPattern
                    className={cn(
                        'mask-[radial-gradient(400px_circle_at_center,white,transparent)]',
                        'inset-x-0 inset-y-[0%] h-full skew-y-12'
                    )}
                />
                <div className='relative z-20 mt-auto'>
                    <blockquote className='space-y-2'>
                        <p className='text-lg'>
                            &ldquo;This starter template has saved me countless hours of work
                            and helped me deliver projects to my clients faster than ever
                            before.&rdquo;
                        </p>
                        <footer className='text-sm'>Random Dude</footer>
                    </blockquote>
                </div>
            </div>
            <div className='flex h-full items-center justify-center p-4 lg:p-8'>
                <div className='flex w-full max-w-md flex-col items-center justify-center space-y-6'>
                    {/* github link  */}
                    <Link
                        className={cn('group inline-flex hover:text-yellow-200')}
                        target='_blank'
                        href={'https://github.com/kiranism/next-shadcn-dashboard-starter'}
                    >
                        <div className='flex items-center'>
                            <GitHubLogoIcon className='size-4' />
                            <span className='ml-1 inline'>Star on GitHub</span>{' '}
                        </div>
                        <div className='ml-2 flex items-center gap-1 text-sm md:flex'>
                            <IconStar
                                className='size-4 text-gray-500 transition-all duration-300 group-hover:text-yellow-300'
                                fill='currentColor'
                            />
                            <span className='font-display font-medium'>{stars}</span>
                        </div>
                    </Link>

                    <div className='w-full space-y-6'>
                        <div className='flex flex-col space-y-2 text-center'>
                            <h1 className='text-2xl font-semibold tracking-tight'>
                                Forgot your password?
                            </h1>
                            <p className='text-muted-foreground text-sm'>
                                Enter your email and we'll send you a reset link
                            </p>
                        </div>

                        <ForgotPasswordForm />
                    </div>

                    <p className='text-muted-foreground px-8 text-center text-sm'>
                        By clicking continue, you agree to our{' '}
                        <Link
                            href='/terms'
                            className='hover:text-primary underline underline-offset-4'
                        >
                            Terms of Service
                        </Link>{' '}
                        and{' '}
                        <Link
                            href='/privacy'
                            className='hover:text-primary underline underline-offset-4'
                        >
                            Privacy Policy
                        </Link>
                        .
                    </p>
                </div>
            </div>
        </div>
    );
}

'use client';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { PasswordInput } from '@/components/ui/password-input';
import { useRouter } from 'next/navigation';
import { signIn } from 'supertokens-web-js/recipe/emailpassword';
import { Icons } from '@/components/icons';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

interface AuthFormProps {
    mode: 'signin' | 'signup';
}

// Zod validation schema
const signInSchema = z.object({
    email: z
        .string()
        .min(1, 'Email is required')
        .email('Please enter a valid email address'),
    password: z
        .string()
        .min(8, 'Password must be at least 8 characters')
});

type SignInFormData = z.infer<typeof signInSchema>;

export function AuthForm({ mode }: AuthFormProps) {
    const router = useRouter();

    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
        setError
    } = useForm<SignInFormData>({
        resolver: zodResolver(signInSchema),
        mode: 'onBlur', // Validate on blur for better UX
        defaultValues: {
            email: '',
            password: ''
        }
    });

    const onSubmit = async (data: SignInFormData) => {
        try {
            if (mode === 'signup') {
                setError('root', {
                    message: 'Sign up is disabled. Please contact your administrator for an invite.'
                });
                return;
            }

            const response = await signIn({
                formFields: [
                    { id: 'email', value: data.email },
                    { id: 'password', value: data.password }
                ]
            });

            if (response.status === 'FIELD_ERROR') {
                setError('root', {
                    message: response.formFields[0].error
                });
            } else if (response.status === 'WRONG_CREDENTIALS_ERROR') {
                setError('root', {
                    message: 'Invalid email or password'
                });
            } else if (response.status === 'SIGN_IN_NOT_ALLOWED') {
                setError('root', {
                    message: 'Sign in is not allowed. Please contact support.'
                });
            } else {
                // Success - redirect to dashboard
                router.push('/dashboard/overview');
            }
        } catch (err) {
            setError('root', {
                message: 'An unexpected error occurred. Please try again.'
            });
            console.error('Auth error:', err);
        }
    };

    return (
        <form onSubmit={handleSubmit(onSubmit)} className="w-full space-y-4">
            <div className="space-y-2">
                <Label htmlFor="email">Email</Label>
                <Input
                    id="email"
                    type="email"
                    placeholder="name@example.com"
                    disabled={isSubmitting}
                    aria-label="Email address"
                    aria-describedby={errors.email ? 'email-error' : undefined}
                    aria-invalid={!!errors.email}
                    {...register('email')}
                />
                {errors.email && (
                    <p
                        id="email-error"
                        role="alert"
                        className="text-sm text-destructive"
                    >
                        {errors.email.message}
                    </p>
                )}
            </div>

            <div className="space-y-2">
                <Label htmlFor="password">Password</Label>
                <PasswordInput
                    id="password"
                    placeholder="Enter your password"
                    disabled={isSubmitting}
                    aria-label="Password"
                    aria-describedby={errors.password ? 'password-error' : undefined}
                    aria-invalid={!!errors.password}
                    {...register('password')}
                />
                {errors.password && (
                    <p
                        id="password-error"
                        role="alert"
                        className="text-sm text-destructive"
                    >
                        {errors.password.message}
                    </p>
                )}
            </div>

            {errors.root && (
                <div
                    role="alert"
                    className="bg-destructive/10 text-destructive rounded-md p-3 text-sm"
                >
                    {errors.root.message}
                </div>
            )}

            <Button
                type="submit"
                className="w-full"
                disabled={isSubmitting}
                aria-busy={isSubmitting}
                aria-live="polite"
            >
                {isSubmitting && <Icons.spinner className="mr-2 h-4 w-4 animate-spin" />}
                {mode === 'signup' ? 'Create Account' : 'Sign In'}
            </Button>
        </form>
    );
}

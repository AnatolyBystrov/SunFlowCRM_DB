'use client';

import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { PasswordInput } from '@/components/ui/password-input';
import { Icons } from '@/components/icons';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useState, useEffect } from 'react';
import {
    submitNewPassword,
    getResetPasswordTokenFromURL
} from 'supertokens-web-js/recipe/emailpassword';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

// Zod validation schema
const resetPasswordSchema = z.object({
    password: z
        .string()
        .min(8, 'Password must be at least 8 characters')
        .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
        .regex(/[0-9]/, 'Password must contain at least one number'),
    confirmPassword: z.string()
}).refine((data) => data.password === data.confirmPassword, {
    message: 'Passwords do not match',
    path: ['confirmPassword']
});

type ResetPasswordFormData = z.infer<typeof resetPasswordSchema>;

export function ResetPasswordForm() {
    const router = useRouter();
    const [token, setToken] = useState<string | null>(null);
    const [resetSuccess, setResetSuccess] = useState(false);

    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
        setError
    } = useForm<ResetPasswordFormData>({
        resolver: zodResolver(resetPasswordSchema),
        mode: 'onBlur',
        defaultValues: {
            password: '',
            confirmPassword: ''
        }
    });

    useEffect(() => {
        // Extract token from URL
        const tokenFromURL = getResetPasswordTokenFromURL();
        if (!tokenFromURL) {
            setError('root', {
                message: 'Invalid or missing reset token. Please request a new password reset link.'
            });
        } else {
            setToken(tokenFromURL);
        }
    }, [setError]);

    const onSubmit = async (data: ResetPasswordFormData) => {
        if (!token) {
            setError('root', {
                message: 'Invalid reset token. Please request a new password reset link.'
            });
            return;
        }

        try {
            const response = await submitNewPassword({
                formFields: [
                    {
                        id: 'password',
                        value: data.password
                    }
                ]
            });

            if (response.status === 'FIELD_ERROR') {
                setError('password', {
                    message: response.formFields[0].error
                });
            } else if (response.status === 'RESET_PASSWORD_INVALID_TOKEN_ERROR') {
                setError('root', {
                    message: 'Reset token is invalid or expired. Please request a new password reset link.'
                });
            } else {
                // Success
                setResetSuccess(true);
                // Redirect to sign-in after 3 seconds
                setTimeout(() => {
                    router.push('/auth/sign-in');
                }, 3000);
            }
        } catch (err) {
            setError('root', {
                message: 'An unexpected error occurred. Please try again.'
            });
            console.error('Reset password error:', err);
        }
    };

    if (resetSuccess) {
        return (
            <div className="space-y-4 text-center">
                <div className="rounded-full bg-green-100 p-3 mx-auto w-fit">
                    <Icons.check className="h-6 w-6 text-green-600" />
                </div>
                <div className="space-y-2">
                    <h3 className="font-semibold text-lg">Password reset successful!</h3>
                    <p className="text-sm text-muted-foreground">
                        Your password has been changed successfully.
                        Redirecting to sign in...
                    </p>
                </div>
                <Link href="/auth/sign-in">
                    <Button variant="outline" className="w-full">
                        Sign In Now
                    </Button>
                </Link>
            </div>
        );
    }

    return (
        <form onSubmit={handleSubmit(onSubmit)} className="w-full space-y-4">
            <div className="space-y-2">
                <Label htmlFor="password">New Password</Label>
                <PasswordInput
                    id="password"
                    placeholder="Enter new password"
                    disabled={isSubmitting || !token}
                    aria-label="New password"
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
                <p className="text-xs text-muted-foreground">
                    Must be at least 8 characters with 1 uppercase letter and 1 number
                </p>
            </div>

            <div className="space-y-2">
                <Label htmlFor="confirmPassword">Confirm Password</Label>
                <PasswordInput
                    id="confirmPassword"
                    placeholder="Confirm new password"
                    disabled={isSubmitting || !token}
                    aria-label="Confirm password"
                    aria-describedby={errors.confirmPassword ? 'confirm-password-error' : undefined}
                    aria-invalid={!!errors.confirmPassword}
                    {...register('confirmPassword')}
                />
                {errors.confirmPassword && (
                    <p
                        id="confirm-password-error"
                        role="alert"
                        className="text-sm text-destructive"
                    >
                        {errors.confirmPassword.message}
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
                disabled={isSubmitting || !token}
                aria-busy={isSubmitting}
                aria-live="polite"
            >
                {isSubmitting && <Icons.spinner className="mr-2 h-4 w-4 animate-spin" />}
                Reset Password
            </Button>

            <div className="text-center">
                <Link
                    href="/auth/sign-in"
                    className="text-sm text-muted-foreground hover:text-primary hover:underline"
                >
                    Back to Sign In
                </Link>
            </div>
        </form>
    );
}

'use client';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Icons } from '@/components/icons';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useState } from 'react';
import { sendPasswordResetEmail } from 'supertokens-web-js/recipe/emailpassword';
import Link from 'next/link';

// Zod validation schema
const forgotPasswordSchema = z.object({
    email: z
        .string()
        .min(1, 'Email is required')
        .email('Please enter a valid email address')
});

type ForgotPasswordFormData = z.infer<typeof forgotPasswordSchema>;

export function ForgotPasswordForm() {
    const [emailSent, setEmailSent] = useState(false);

    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
        setError
    } = useForm<ForgotPasswordFormData>({
        resolver: zodResolver(forgotPasswordSchema),
        mode: 'onBlur',
        defaultValues: {
            email: ''
        }
    });

    const onSubmit = async (data: ForgotPasswordFormData) => {
        try {
            const response = await sendPasswordResetEmail({
                formFields: [
                    {
                        id: 'email',
                        value: data.email
                    }
                ]
            });

            if (response.status === 'FIELD_ERROR') {
                setError('email', {
                    message: response.formFields[0].error
                });
            } else if (response.status === 'PASSWORD_RESET_NOT_ALLOWED') {
                setError('root', {
                    message: 'Password reset is not allowed for this account. Please contact support.'
                });
            } else {
                // Success - email sent
                setEmailSent(true);
            }
        } catch (err) {
            setError('root', {
                message: 'An unexpected error occurred. Please try again.'
            });
            console.error('Forgot password error:', err);
        }
    };

    if (emailSent) {
        return (
            <div className="space-y-4 text-center">
                <div className="rounded-full bg-green-100 p-3 mx-auto w-fit">
                    <Icons.check className="h-6 w-6 text-green-600" />
                </div>
                <div className="space-y-2">
                    <h3 className="font-semibold text-lg">Check your email</h3>
                    <p className="text-sm text-muted-foreground">
                        We've sent a password reset link to your email address.
                        Please check your inbox and follow the instructions.
                    </p>
                </div>
                <Link href="/auth/sign-in">
                    <Button variant="outline" className="w-full">
                        Back to Sign In
                    </Button>
                </Link>
            </div>
        );
    }

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
                Send Reset Link
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

import EmailPasswordReact from 'supertokens-auth-react/recipe/emailpassword';
import SessionReact from 'supertokens-auth-react/recipe/session';
import { SuperTokensConfig } from 'supertokens-auth-react/lib/build/types';

const appInfo = {
    appName: process.env.NEXT_PUBLIC_APP_NAME || 'Next Shadcn Dashboard',
    apiDomain: process.env.NEXT_PUBLIC_API_DOMAIN || 'http://localhost:3000',
    websiteDomain: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
    apiBasePath: process.env.NEXT_PUBLIC_API_BASE_PATH || '/api/auth',
    websiteBasePath: '/auth'
};

export const frontendConfig = (): SuperTokensConfig => {
    return {
        appInfo,
        recipeList: [
            EmailPasswordReact.init({
                signInAndUpFeature: {
                    signUpForm: {
                        formFields: [
                            {
                                id: 'email',
                                label: 'Email',
                                placeholder: 'Enter your email'
                            },
                            {
                                id: 'password',
                                label: 'Password',
                                placeholder: 'Enter your password'
                            }
                        ]
                    }
                }
            }),
            SessionReact.init({
                tokenTransferMethod: 'cookie',
                sessionTokenBackendDomain: process.env.NEXT_PUBLIC_SESSION_TOKEN_BACKEND_DOMAIN
            })
        ],
        // Disable default UI routing (we'll use custom UI)
        disableAuthRoute: false,
        enableDebugLogs: process.env.NODE_ENV === 'development'
    };
};

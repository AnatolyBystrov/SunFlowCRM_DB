<h1 align="center">Admin Dashboard Starter Template with Next.js &amp; Shadcn UI</h1>

<div align="center">Open source admin dashboard starter built with Next.js 16, shadcn/ui, Tailwind CSS, TypeScript</div>

<br />

<div align="center">
  <a href="https://dub.sh/shadcn-dashboard"><strong>View Demo</strong></a>
</div>
<br />
<div align="center">
  <img src="/public/shadcn-dashboard.png" alt="Shadcn Dashboard Cover" style="max-width: 100%; border-radius: 8px;" />
</div>

<p align="center">
  <a href="https://github.com/Kiranism/next-shadcn-dashboard-starter/stargazers"><img src="https://img.shields.io/github/stars/Kiranism/next-shadcn-dashboard-starter?style=social" alt="GitHub stars" /></a>
  <a href="https://github.com/Kiranism/next-shadcn-dashboard-starter/network/members"><img src="https://img.shields.io/github/forks/Kiranism/next-shadcn-dashboard-starter?style=social" alt="Forks" /></a>
  <a href="https://github.com/Kiranism/next-shadcn-dashboard-starter/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Kiranism/next-shadcn-dashboard-starter" alt="MIT License" /></a>
  <img src="https://img.shields.io/badge/Next.js-16-black" alt="Next.js" />
  <a href="https://go.clerk.com/ILdYhn7"><img src="https://img.shields.io/badge/Sponsored_by-Clerk-6C47FF?style=flat-square&logo=clerk" alt="Sponsored by Clerk" /></a>
</p>

## Overview

This is an **open source admin dashboard starter** built with **Next.js 16, Shadcn UI, TypeScript, and Tailwind CSS**.

It gives you a production-ready **dashboard UI** with authentication, charts, tables, forms, and a feature-based folder structure, perfect for **SaaS apps, internal tools, and admin panels**.

### Tech Stack

This template uses the following stack:

- Framework - ⚡ **[Next.js 16](https://nextjs.org/)** with App Router
- 🔐 **[SuperTokens](https://supertokens.com/)** for self-hosted authentication
- 🎨 **[shadcn/ui](https://ui.shadcn.com/)** for beautiful, accessible components
- 🎭 **[Tailwind CSS](https://tailwindcss.com/)** for styling
- 📊 **Dashboard** with sidebar navigation
- 🌓 **Dark mode** support
- 📱 **Responsive** design
- 🔒 **Protected routes** with session management
- 🎯 **TypeScript** for type safety
- Error tracking - [Sentry](https://sentry.io/for/nextjs/?utm_source=github&utm_medium=paid-community&utm_campaign=general-fy26q2-nextjs&utm_content=github-banner-project-tryfree)
- Components - [Shadcn-ui](https://ui.shadcn.com)
- Schema Validations - [Zod](https://zod.dev)
- State Management - [Zustand](https://zustand-demo.pmnd.rs)
- Search params state manager - [Nuqs](https://nuqs.47ng.com/)
- Tables - [Tanstack Data Tables](https://ui.shadcn.com/docs/components/data-table) • [Dice table](https://www.diceui.com/docs/components/data-table)
- Forms - [React Hook Form](https://ui.shadcn.com/docs/components/form)
- Command+k interface - [kbar](https://kbar.vercel.app/)
- Linting - [ESLint](https://eslint.org)
- Pre-commit Hooks - [Husky](https://typicode.github.io/husky/)
- Formatting - [Prettier](https://prettier.io)
- Themes - [tweakcn](https://tweakcn.com/)

_If you are looking for a Tanstack start dashboard template, here is the [repo](https://git.new/tanstack-start-dashboard)._

## Features

- 🧱 Pre-built **admin dashboard layout** (sidebar, header, content area)

- 📊 **Analytics overview** page with cards and charts

- 📋 **Data tables** with server-side search, filter & pagination

- 🔐 **Authentication** & user management via SuperTokens

- 🏢 **Multi-tenant workspaces** with SuperTokens Organizations (create, switch, manage teams)

- 💳 **Billing & subscriptions** with SuperTokens Billing for B2B (plan management, feature gating)

- 🔒 **RBAC navigation system** - Fully client-side navigation filtering based on organization, permissions, and roles

- ℹ️ **Infobar component** to show helpful tips, status messages, or contextual info on any page

- 🧩 **Shadcn UI components** with Tailwind CSS styling

- 🎨 **Multi-theme support** with 6+ beautiful themes and easy theme switching

- 🧠 Feature-based folder structure for scalable projects

- ⚙️ Ready for **SaaS dashboards**, internal tools, and client admin panels

## Use Cases

You can use this Next.js + Shadcn UI dashboard starter to build:

- SaaS admin dashboards

- Internal tools & operations panels

- Analytics dashboards

- Client project admin panels

- Boilerplate for new Next.js admin UI projects

## Pages

| Pages                                                                                                                                                                  | Specifications                                                                                                                                                                                                                                                          |
| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Signup / Signin](https://go.clerk.com/ILdYhn7)                                                                                                                        | Authentication with **SuperTokens** provides secure authentication and user management with multiple sign-in options including passwordless authentication, social logins, and enterprise SSO - all designed to enhance security while delivering a seamless user experience. |
| [Dashboard Overview](https://shadcn-dashboard.kiranism.dev/dashboard)                                                                                                  | Cards with Recharts graphs for analytics. Parallel routes in the overview sections feature independent loading, error handling, and isolated component rendering.                                                                                                       |
| [Product List (Table)](https://shadcn-dashboard.kiranism.dev/dashboard/product)                                                                                        | Tanstack tables with server side searching, filter, pagination by Nuqs which is a Type-safe search params state manager in nextjs                                                                                                                                       |
| [Create Product Form](https://shadcn-dashboard.kiranism.dev/dashboard/product/new)                                                                                     | A Product Form with shadcn form (react-hook-form + zod).                                                                                                                                                                                                                |
| [Profile](https://shadcn-dashboard.kiranism.dev/dashboard/profile)                                                                                                     | SuperTokens' full-featured account management UI that allows users to manage their profile and security settings                                                                                                                                                             |
| [Kanban Board](https://shadcn-dashboard.kiranism.dev/dashboard/kanban)                                                                                                 | A Drag n Drop task management board with dnd-kit and zustand to persist state locally.                                                                                                                                                                                  |
| [Workspaces](https://shadcn-dashboard.kiranism.dev/dashboard/workspaces)                                                                                               | Organization management page using SuperTokens' `<OrganizationList />` component. Users can view, create, and switch between organizations/workspaces.                                                                                                                       |
| [Team Management](https://shadcn-dashboard.kiranism.dev/dashboard/workspaces/team)                                                                                     | Full-featured team management interface using SuperTokens' `<OrganizationProfile />` component. Manage members, roles, permissions, security settings, and organization details. Requires an active organization.                                                            |
| [Billing & Plans](https://shadcn-dashboard.kiranism.dev/dashboard/billing)                                                                                             | Billing management page using SuperTokens' `<PricingTable />` component. Organizations can view available plans, subscribe, and manage subscriptions. Requires an active organization.                                                                                       |
| [Exclusive Page](https://shadcn-dashboard.kiranism.dev/dashboard/exclusive)                                                                                            | Example of plan-based access control using SuperTokens' `<Protect>` component. This page is only accessible to organizations on the Pro plan, demonstrating feature gating with fallback UI.                                                                                 |
| [Not Found](https://shadcn-dashboard.kiranism.dev/dashboard/notfound)                                                                                                  | Not Found Page Added in the root level                                                                                                                                                                                                                                  |
| [Global Error](https://sentry.io/for/nextjs/?utm_source=github&utm_medium=paid-community&utm_campaign=general-fy26q2-nextjs&utm_content=github-banner-project-tryfree) | A centralized error page that captures and displays errors across the application. Integrated with **Sentry** to log errors, provide detailed reports, and enable replay functionality for better debugging.                                                            |

## Feature based organization

```plaintext
src/
├── app/ # Next.js App Router directory
│ ├── (auth)/ # Auth route group
│ │ ├── (signin)/
│ ├── (dashboard)/ # Dashboard route group
│ │ ├── layout.tsx
│ │ ├── loading.tsx
│ │ └── page.tsx
│ └── api/ # API routes
│
├── components/ # Shared components
│ ├── ui/ # UI components (buttons, inputs, etc.)
│ └── layout/ # Layout components (header, sidebar, etc.)
│
├── features/ # Feature-based modules
│ ├── feature/
│ │ ├── components/ # Feature-specific components
│ │ ├── actions/ # Server actions
│ │ ├── schemas/ # Form validation schemas
│ │ └── utils/ # Feature-specific utilities
│ │
├── lib/ # Core utilities and configurations
│ ├── auth/ # Auth configuration
│ ├── db/ # Database utilities
│ └── utils/ # Shared utilities
│
├── hooks/ # Custom hooks
│ └── use-debounce.ts
│
├── stores/ # Zustand stores
│ └── dashboard-store.ts
│
└── types/ # TypeScript types
└── index.ts
```

## Getting Started

> [!NOTE]  
> This admin dashboard starter uses **Next.js 16 (App Router)** with **React 19** and **Shadcn UI**. Follow these steps to run it locally:

Clone the repo:

```
git clone https://github.com/Kiranism/next-shadcn-dashboard-starter.git
```

- `bun install`
- Create a `.env.local` file by copying the example environment file:
  `cp env.example.txt .env.local`
- Add the required environment variables to the `.env.local` file.
- `bun run dev`

## 🔐 Authentication Setup

This starter uses **SuperTokens** for self-hosted authentication.

### Quick Start

1.  **Start SuperTokens Core** (included in docker-compose):
    ```bash
    docker-compose up -d supertokens
    ```

2.  **Configure environment variables** in `.env.local`:
    ```env
    NEXT_PUBLIC_APP_NAME="Your App Name"
    NEXT_PUBLIC_APP_URL="http://localhost:3000"
    NEXT_PUBLIC_API_DOMAIN="http://localhost:3000"
    SUPERTOKENS_CONNECTION_URI="http://localhost:3567"
    ```

3.  **Start the development server**:
    ```bash
    npm run dev
    ```

For detailed setup instructions, see [docs/supertokens_setup.md](docs/supertokens_setup.md).

You should now be able to access the application at http://localhost:3000.

> [!WARNING]
> After cloning or forking the repository, be cautious when pulling or syncing with the latest changes, as this may result in breaking conflicts.

---

#### Cleanup

To remove demo data, boilerplate, or unwanted starter code, see the [cleanup guide](__CLEANUP__/cleanup.md). Follow the instructions there to tidy up, adapt, or personalize your app as needed for your project.

### ⭐ Support

If you find this template helpful, please consider giving it a star ⭐
You can also buy me a coffee if you'd like!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow?style=flat-square&logo=buymeacoffee)](https://buymeacoffee.com/kir4n)

Cheers! 🥂

<!--

SEO keywords:

open source admin dashboard, nextjs admin dashboard, nextjs dashboard template,

shadcn ui dashboard, admin dashboard starter, next.js 16, typescript dashboard,

dashboard ui template, nextjs shadcn admin panel, react admin dashboard,

tailwind css admin dashboard

-->

---

## Star History

<a href="https://www.star-history.com/#Kiranism/next-shadcn-dashboard-starter&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=Kiranism/next-shadcn-dashboard-starter&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=Kiranism/next-shadcn-dashboard-starter&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=Kiranism/next-shadcn-dashboard-starter&type=date&legend=top-left" />
 </picture>
</a>

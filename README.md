# Skunk Works

**Internal agent workflow application for 207 Analytix.**

Skunk Works is the proprietary internal tool used by 207 Analytix agents to process information, manage customer engagements, and coordinate Human Associate (HA) task assignments across all five service tiers.

## Purpose

Every customer interaction begins with an intake submission and flows through a defined tier workflow. Skunk Works is the interface that allows agents to:

- View and act on incoming intake submissions
- Manage engagement progression across service tiers
- Assign and track Human Associate responsibilities
- Log engagement steps and completion events
- Trigger and authorize AI parse jobs for Alexandria

## Service Tiers Supported

| Tier | Name |
|------|------|
| 1 | Web Application Expertise |
| 2 | Data Stewardship |
| 3 | Expert Data Analysis |
| 4 | Data Education |
| 5 | Custom Consultation |

## Agent Roles

- **Sales Agent** — Customer-facing intake and prospecting
- **Operator Agent** — Information translation and processing
- **Quality Agent** — Data integrity and verification
- **Accountant** — Revenue allocation and Profit First enforcement
- **Database Developer** — System security and effectiveness
- **Customer Wrangler** — Onboarding and retention
- **Operations Developer** — System integration and maintenance

## Stack

- **Frontend:** HTML/CSS/JS hosted on GitHub Pages
- **Backend:** Supabase (PostgreSQL + Auth + Edge Functions)
- **Auth:** Google SSO via @afferentsignal.com Workspace

## Related Repos

- [`207-analytix/alexandria`](https://github.com/207-analytix/alexandria) — Database schema & migrations
- [`207-analytix/credential-broker`](https://github.com/207-analytix/credential-broker) — Internal credential vault
- [`207-analytix/207-docs`](https://github.com/207-analytix/207-docs) — Internal documentation

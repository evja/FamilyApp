# FamilyHub

## Project Overview

FamilyHub is a family management platform where families can organize members, define shared values and vision statements, and track issues as challenges (framed as "opportunities for growth"). Families are multi-user — members are invited via email tokens. The app includes Stripe subscription billing and an admin dashboard for lead management.

## Tech Stack

- **Ruby**: 3.2.2
- **Rails**: 7.1.5.1
- **Database**: PostgreSQL
- **Auth**: Devise (database_authenticatable, registerable, recoverable, rememberable, validatable)
- **CSS**: Tailwind CSS via `tailwindcss-rails`
- **JS**: Importmap Rails, Turbo, Stimulus, Alpine.js (CDN)
- **Payments**: Stripe (subscription mode)
- **Server**: Puma
- **Deployment**: Docker + Heroku

## Development

```sh
rails s              # starts Rails server + Tailwind watcher (Procfile.dev)
bin/rails test       # Minitest suite with fixtures
```

Database names: `family_app_development`, `family_app_test`. Production uses `DATABASE_URL`.

## Models & Relationships

```
User
  belongs_to :family (optional)
  # Devise handles auth. Has admin flag. Last user destroys family on delete.

Family
  has_many :users (dependent: nullify)
  has_many :members (dependent: destroy)
  has_many :family_values (dependent: destroy)
  has_many :issues (dependent: destroy)
  has_many :invitations (FamilyInvitation, dependent: destroy)
  has_one  :vision (FamilyVision, dependent: destroy)
  includes Themeable concern (7 theme presets: forest, ocean, sunset, earth, olive, slate, rosegold)

Member
  belongs_to :family
  has_many :issues, through: :issue_members
  # Represents a person in the family (name, age, personality, interests, health, etc.)

Issue
  belongs_to :family
  belongs_to :root_issue (self-referential, optional)
  has_many :symptom_issues (self-referential via root_issue_id)
  has_many :members, through: :issue_members
  has_many :family_values, through: :issue_values
  # Types: "root" or "symptom". Urgency: Low/Medium/High. List: Family/Marriage/Personal.

FamilyValue
  belongs_to :family

FamilyVision
  belongs_to :family
  # Fields: mission_statement, notes, ten_year_dream

FamilyInvitation
  belongs_to :family
  # Token-based, 7-day expiration. Statuses: pending, accepted, expired.

Lead
  # Email capture from landing page, no associations.

Join tables: IssueMember, IssueValue
```

## Route Structure

All family resources are nested under `/families/:family_id/`:
- `/families/:family_id/members`
- `/families/:family_id/issues` (+ collection route `solve`)
- `/families/:family_id/family_invitations`
- `/families/:family_id/vision` (singular resource)
- `/families/:family_id/vision/values` (nested under vision)

Other routes:
- `/` — landing page (redirects to family if logged in)
- `/about` — static page
- `/leads` — lead capture POST
- `/invitations/:token/accept` — invitation acceptance
- `/billing` and `/billing/checkout` — Stripe integration
- `/admin/dashboard` and `/admin/leads` — admin area

## Authorization Pattern

All family-scoped controllers use this pattern (defined in `ApplicationController`):

1. `before_action :authenticate_user!` — Devise login gate
2. `before_action :authorize_family!` — sets `@family = current_user.family` and rejects if the URL's `family_id` doesn't match

`FamiliesController` has its own `set_family` that does the same thing but checks `params[:id]` instead of `params[:family_id]`.

`FamilyInvitationsController` uses its own `ensure_family_member` check that calls `family.can_be_accessed_by?(user)`.

## Key Patterns & Conventions

- **Theme system**: CSS custom properties in `theme.css.erb`, switched via `data-theme` attribute on body. The `Themeable` concern on `Family` defines `THEME_PRESETS`.
- **Nested resources**: Everything hangs off `/families/:family_id/`. Controllers receive `params[:family_id]`.
- **Issue hierarchy**: Issues can be "root" or "symptom". Symptoms link to a root issue via `root_issue_id`.
- **Invitations**: Token-based with 7-day expiry. `FamilyMailer.invitation_email` sends the link.
- **Admin**: Guarded by `require_admin` checking `current_user.admin?`. Located in `Admin::` namespace.
- **No API**: This is a server-rendered app. No JSON endpoints beyond what Jbuilder scaffolding may have left.

## Things to Watch Out For

- **`current_family` helper** in `ApplicationController` still does an unscoped `Family.find_by` as a fallback. It's used in views (helper_method) but should not be trusted for authorization — always use `@family` set by `authorize_family!`.
- **Stripe price ID is hardcoded** in `BillingController#checkout`. Will need updating if the Stripe plan changes.
- **Devise email sender** in `config/initializers/devise.rb` likely needs updating for production.
- **`IssueMember` model** has incorrect associations (`has_many :issue_members` and `has_many :issues, through: :issue_members` on a join model) — these are dead code but could cause confusion.
- **No test coverage for authorization**. The auth fixes (authenticate_user!, authorize_family!) don't have corresponding controller tests yet.
- **Alpine.js loaded via CDN** — no pinned version, could break on major update.
- **`FamiliesController#new`** doesn't `return` after the redirect when user already has a family, so `@family = Family.new` always runs.

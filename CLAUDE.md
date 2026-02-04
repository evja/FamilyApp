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
  has_one :member (dependent: nullify)
  # Devise handles auth. Has admin flag. Last user destroys family on delete.
  # Methods: family_admin?, family_parent?, family_role

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
  belongs_to :user (optional)
  has_many :issues, through: :issue_members
  has_one :invitation (FamilyInvitation)
  # Represents a person in the family (name, age, personality, interests, health, etc.)
  # Roles: admin_parent, parent, teen, child (ROLES constant)
  # Only admin_parent/parent/teen can have accounts (can_have_account?)
  # Fields: role, email, invited_at, joined_at
  # Scopes: admin_parents, invitable, pending_invitation, with_accounts

Issue
  belongs_to :family
  belongs_to :root_issue (self-referential, optional)
  has_many :symptom_issues (self-referential via root_issue_id)
  has_many :members, through: :issue_members
  has_many :family_values, through: :issue_values
  # Types: "root" or "symptom". Urgency: Low/Medium/High. List: Family/Marriage/Personal.
  # Status flow: new → acknowledged → working_on_it → resolved
  # Scopes: active (not resolved), resolved, resolved_this_week

IssueAssist
  belongs_to :family
  belongs_to :user
  # Logs AI writing assistant usage. Daily limit of 20 per family.

FamilyValue
  belongs_to :family

FamilyVision
  belongs_to :family
  # Fields: mission_statement, notes, ten_year_dream

FamilyInvitation
  belongs_to :family
  belongs_to :member (optional)
  # Token-based, 7-day expiration. Statuses: pending, accepted, expired.
  # Member-first: invitations are now linked to members via member_id
  # Legacy invitations (without member_id) are still supported

Lead
  # Email capture from landing page, no associations.

Join tables: IssueMember, IssueValue, IssueAssist
```

## Route Structure

All family resources are nested under `/families/:family_id/`:
- `/families/:family_id/members` (+ member routes `invite`, `resend_invite`)
- `/families/:family_id/issues` (+ collection route `solve`, member route `advance_status`)
- `/families/:family_id/issue_assists` (POST only — AI writing assistant)
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

**RoleAuthorization Concern** (`app/controllers/concerns/role_authorization.rb`):
- `current_member` helper — returns the Member record for the current user
- `require_parent_access!` — checks if user has parent or admin_parent role
- `require_admin_access!` — checks if user is the family admin

## Key Patterns & Conventions

- **Theme system**: CSS custom properties in `theme.css.erb`, switched via `data-theme` attribute on body. The `Themeable` concern on `Family` defines `THEME_PRESETS`.
- **Nested resources**: Everything hangs off `/families/:family_id/`. Controllers receive `params[:family_id]`.
- **Issue hierarchy**: Issues can be "root" or "symptom". Symptoms link to a root issue via `root_issue_id`.
- **Invitations (Member-First)**: Members must be created first, then invited. Only members with role=admin_parent/parent/teen can receive invitations. Invitations are linked to members via `member_id`. Token-based with 7-day expiry. `FamilyMailer.invitation_email` sends the link. When accepted, user is linked to the member via `user_id` and `joined_at` is set.
- **Member Roles**: `admin_parent` (one per family, created automatically), `parent`, `teen`, `child`. Admin_parent/parent roles set `is_parent=true` for backward compatibility via `sync_is_parent_with_role` callback.
- **Admin**: Guarded by `require_admin` checking `current_user.admin?`. Located in `Admin::` namespace.
- **No API**: This is a server-rendered app. JSON endpoints: `IssueAssistsController#create` (issue writing assistant) and `FamilyVisionsController#assist` (vision mission statement suggestions).
- **Issue status flow**: Issues progress through `new → acknowledged → working_on_it → resolved`. One-click `advance_status` action moves to next step. `resolved_at` timestamp is set when reaching resolved.
- **AI writing assistant**: `IssueAssistant` service calls Anthropic API (Claude Haiku) via `Net::HTTP`. Rate limited to 20 per family per day via `IssueAssist` model. API key stored in `Rails.application.credentials.dig(:anthropic, :api_key)`. Gracefully degrades if key is not configured.
- **Vision Builder**: 4-step Alpine.js wizard (Values → Mission Statement → 10-Year Dream → Review & Save) in `family_visions/edit.html.erb`. Values are synced via delete-all + recreate on save. `VisionAssistant` service generates 3 mission statement suggestions from selected values (same Anthropic API pattern as `IssueAssistant`). Rate limiting reuses `IssueAssist` table (shared family-wide 20/day limit). Route: `POST /families/:family_id/vision/assist`.
- **Dashboard stats**: Issues card shows "X open · Y resolved this week" counts from `@open_issue_count` and `@resolved_this_week_count` set in `FamiliesController#show`.

## MVP Simplification

The app has been simplified for MVP launch. Fields and features are hidden from the UI but preserved in the database for future use.

### Dashboard Card Visibility
- **MVP cards** (visible to all users): Members, Issues, Vision
- **Non-MVP cards** (Rhythms, Responsibilities, Rituals, Relationships): only visible to admins when not in "View as User" mode, with an "Admin Preview - Hidden from users" badge
- Controlled by the `show_admin_features?` helper in `ApplicationController`

### Simplified Forms
- **Member form** (`members/_form.html.erb`): shows name, age, role dropdown (Parent/Teen/Child), and email field (shown via Alpine.js for parent/teen roles). Hidden fields (personality, interests, health, needs, development) remain in DB schema and strong params.
- **Member show page** (`members/show.html.erb`): MVP fields only — avatar, name, age, role (Parent/Child), edit/delete actions. Health, Interests, Needs, and Quarterly Assessments cards removed.
- **Member card** (`members/_member_card.html.erb`): shows "Parent" or "Child" role label for all members.
- **Member card with status** (`members/_member_card_with_status.html.erb`): shows member with status badge (You, Admin, Joined, Pending, Not Invited) and Invite/Resend buttons for eligible members.
- **Members index** (`members/index.html.erb`): groups members by role (Admin Parent, Parents, Teens, Children) with status badges and invite actions.
- **Issue form** (`issues/_form.html.erb`): shows only description and urgency. Hidden fields (list_type, member_ids, family_value_ids, issue_type, root_issue_id) remain in DB. `IssuesController` defaults `list_type` to "Family" and `issue_type` to "root" when not provided.
- **Vision show page** (`family_visions/show.html.erb`): empty state with "Start Building Your Vision" CTA when no vision data exists; populated state shows values tags, mission statement card, 10-year dream card, and last updated date.

### Admin "View as User" Toggle
- Admins can toggle a "View as User" mode via `session[:view_as_user]`
- Route: `POST /admin/toggle_view_as_user`
- When active, `show_admin_features?` returns false, hiding non-MVP dashboard cards and showing a yellow banner
- Helper methods: `viewing_as_user?`, `show_admin_features?` (both exposed as `helper_method` in `ApplicationController`)

## Things to Watch Out For

- **`current_family` helper** in `ApplicationController` still does an unscoped `Family.find_by` as a fallback. It's used in views (helper_method) but should not be trusted for authorization — always use `@family` set by `authorize_family!`.
- **Stripe price ID is hardcoded** in `BillingController#checkout`. Will need updating if the Stripe plan changes.
- **Devise email sender** in `config/initializers/devise.rb` likely needs updating for production.
- **`IssueMember` model** has incorrect associations (`has_many :issue_members` and `has_many :issues, through: :issue_members` on a join model) — these are dead code but could cause confusion.
- **No test coverage for authorization**. The auth fixes (authenticate_user!, authorize_family!) don't have corresponding controller tests yet.
- **Alpine.js loaded via CDN** — no pinned version, could break on major update.
- **`FamiliesController#new`** doesn't `return` after the redirect when user already has a family, so `@family = Family.new` always runs.

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
  has_many :rhythms (dependent: destroy)
  has_one  :vision (FamilyVision, dependent: destroy)
  includes Themeable concern (7 theme presets: forest, ocean, sunset, earth, olive, slate, rosegold)

Member
  belongs_to :family
  belongs_to :user (optional)
  has_many :issues, through: :issue_members
  has_one :invitation (FamilyInvitation)
  has_many :thrive_assessments (dependent: destroy)
  # Represents a person in the family (name, age, birthdate, personality, interests, health, etc.)
  # Roles: admin_parent, parent, teen, child (ROLES constant)
  # Only admin_parent/parent/teen can have accounts (can_have_account?)
  # Fields: role, email, birthdate, invited_at, joined_at
  # Scopes: admin_parents, invitable, pending_invitation, with_accounts
  # Birthdate: Optional. When set, age is auto-calculated and child/teen role is auto-assigned (TEEN_AGE_THRESHOLD = 13)
  # Methods: calculated_age, role_for_age(age) — returns existing role if age is nil to prevent validation errors

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

Rhythm
  belongs_to :family
  has_many :agenda_items (ordered by position, dependent: destroy)
  has_many :completions (RhythmCompletion, dependent: destroy)
  # Recurring family meetings (daily, weekly, biweekly, monthly, quarterly, annually)
  # Categories: parent_sync, family_huddle, retreat, check_in, custom
  # Status: overdue, due_soon, on_track, inactive
  # Methods: start_meeting!, complete!, skip!, current_meeting

AgendaItem
  belongs_to :rhythm
  has_many :completion_items (dependent: destroy)
  # Individual items in a rhythm's agenda
  # Fields: title, instructions, duration_minutes, position, link_type
  # LINK_TYPES: none, issues, vision, members, thrive
  # Scopes: ordered (by position)
  # Methods: has_link?, link_path(family), link_available?, duration_display

RhythmCompletion
  belongs_to :rhythm
  belongs_to :completed_by (User, optional)
  has_many :completion_items (dependent: destroy)
  has_many :thrive_assessments (dependent: nullify)
  # Tracks a single run of a rhythm meeting
  # Statuses: in_progress, completed, abandoned
  # Methods: progress_percentage, all_items_checked?, duration_display

CompletionItem
  belongs_to :rhythm_completion
  belongs_to :agenda_item
  # Tracks checked/unchecked state of each agenda item during a meeting
  # Scopes: checked, unchecked, ordered
  # Methods: check!, uncheck!, toggle!

ThriveAssessment
  belongs_to :member
  belongs_to :completed_by (User, optional)
  belongs_to :rhythm_completion (optional)
  # Child/teen wellness check-in assessments
  # Rating fields (1-5): mind_rating, body_rating, spirit_rating, responsibility_rating
  # Notes fields: mind_notes, body_notes, spirit_notes, responsibility_notes
  # Summary fields: whats_working, whats_not_working, action_items
  # Immutable after creation (readonly? returns true when persisted)
  # Only for children/teens (validated)
  # Scopes: recent, for_member, in_date_range

Relationship
  belongs_to :family
  belongs_to :member_low (Member)
  belongs_to :member_high (Member)
  has_many :assessments (RelationshipAssessment, dependent: destroy)
  # Tracks relationships between pairs of family members
  # member_low_id < member_high_id ensures uniqueness (no duplicate pairs)
  # Methods: display_name, assessed?, current_health_score, current_health_band, health_label, health_color_hsl, last_assessed_at
  # Scopes: healthy, needs_attention, unassessed
  # Family method: ensure_all_relationships! creates missing pairs

RelationshipAssessment
  belongs_to :relationship
  belongs_to :assessor (User, optional)
  # Tracks health of a relationship over time
  # Score fields (0-2): score_cooperation, score_affection, score_trust
  # Notes fields: whats_working, whats_not_working, action_items
  # Methods: total_score (0-6), band_label, assessed_on
  # SCORE_LABELS constant for display
  # Scopes: recent

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
- `/families/:family_id/rhythms` (+ collection routes `setup`, `update_setup`; member routes `start`, `run`, `check_item`, `uncheck_item`, `finish`, `skip`)
- `/families/:family_id/rhythms/:rhythm_id/agenda_items` (CRUD for agenda items)
- `/families/:family_id/relationships` (+ collection route `graph_data`; member routes `assess`, `create_assessment`)

Other routes:
- `/` — landing page (redirects to family if logged in)
- `/about` — static page
- `/leads` — lead capture POST
- `/invitations/:token/accept` — invitation acceptance
- `/billing` and `/billing/checkout` — Stripe integration
- `/admin/dashboard` and `/admin/leads` — admin area
- `/admin/toggle_view_as_user` — toggle "View as User" mode
- `/admin/toggle_module_visibility` — toggle dashboard module visibility

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

**Controllers using RoleAuthorization**:
- `RhythmsController` — `require_parent_access!` on CRUD + setup actions
- `IssuesController` — `require_parent_access!` on CRUD actions (children cannot create/edit issues)

## Key Patterns & Conventions

- **Theme system**: CSS custom properties in `theme.css.erb`, switched via `data-theme` attribute on body. The `Themeable` concern on `Family` defines `THEME_PRESETS`.
- **Nested resources**: Everything hangs off `/families/:family_id/`. Controllers receive `params[:family_id]`.
- **Issue hierarchy**: Issues can be "root" or "symptom". Symptoms link to a root issue via `root_issue_id`.
- **Invitations (Member-First)**: Members must be created first, then invited. Only members with role=admin_parent/parent/teen can receive invitations. Invitations are linked to members via `member_id`. Token-based with 7-day expiry. `FamilyMailer.invitation_email` sends the link. When accepted, user/member/invitation updates are wrapped in a transaction for atomicity.
- **Member Roles**: `admin_parent` (one per family, created automatically), `parent`, `teen`, `child`. Admin_parent/parent roles set `is_parent=true` for backward compatibility via `sync_is_parent_with_role` callback.
- **Member Birthdate & Auto-Role**: Optional `birthdate` field on Member. When set, age is auto-calculated from birthdate, and child/teen role is auto-assigned based on age (13+ = teen, under 13 = child). Parent roles (`admin_parent`, `parent`) are never auto-assigned and must be set manually. If birthdate is not provided, age and role can be set manually as before.
- **Admin**: Guarded by `require_admin` checking `current_user.admin?`. Located in `Admin::` namespace.
- **No API**: This is a server-rendered app. JSON endpoints: `IssueAssistsController#create` (issue writing assistant) and `FamilyVisionsController#assist` (vision mission statement suggestions).
- **Issue status flow**: Issues progress through `new → acknowledged → working_on_it → resolved`. One-click `advance_status` action moves to next step. `resolved_at` timestamp is set when reaching resolved.
- **AI writing assistant**: `IssueAssistant` service calls Anthropic API (Claude Haiku) via `Net::HTTP`. Rate limited to 20 per family per day via `IssueAssist` model. API key stored in `Rails.application.credentials.dig(:anthropic, :api_key)`. Gracefully degrades if key is not configured.
- **Vision Builder**: 4-step Alpine.js wizard (Values → Mission Statement → 10-Year Dream → Review & Save) in `family_visions/edit.html.erb`. Values are synced via delete-all + recreate on save, wrapped in a transaction that rolls back on validation failure. `VisionAssistant` service generates 3 mission statement suggestions from selected values (same Anthropic API pattern as `IssueAssistant`). Rate limiting reuses `IssueAssist` table (shared family-wide 20/day limit). Route: `POST /families/:family_id/vision/assist`.
- **Dashboard stats**: Issues card shows "X open · Y resolved this week" counts from `@open_issue_count` and `@resolved_this_week_count` set in `FamiliesController#show`.
- **Rhythms module**: Recurring family meetings with customizable agendas. Rhythms have frequency settings (daily to annually) and categories (parent_sync, family_huddle, retreat, check_in, custom). Each rhythm has agenda items with optional links to other sections (issues, vision, members, thrive). Meeting flow: start → check items → finish. Progress is tracked via `RhythmCompletion` and `CompletionItem` records. Turbo Streams used for real-time checkbox updates without page scroll.
- **Agenda Items**: Managed via `AgendaItemsController` nested under rhythms. Each item has title, instructions, duration, position, and optional link type. Items are displayed in order during meeting runs. CRUD available from rhythm edit page.
- **Thrive Assessments**: Child/teen wellness check-ins with 4 dimensions (mind, body, spirit, responsibility) rated 1-5. Assessments are immutable after creation. Can be linked to a `RhythmCompletion` when done during a retreat. Only members with role `child` or `teen` can have assessments.
- **Relationships module**: Tracks relationships between all pairs of family members. `Family#ensure_all_relationships!` auto-creates missing pairs. Each relationship can be assessed with cooperation/affection/trust scores (0-2 each, 6 total). Health bands: high (5-6), functioning (3-4), low (0-2). Relationship graph visualization uses SVG with D3-like positioning. Clicking a line or "Assess" link navigates to a standard assessment page (not a modal).

## MVP Simplification

The app has been simplified for MVP launch. Fields and features are hidden from the UI but preserved in the database for future use.

### Dashboard Card Visibility
- **All modules**: Members, Issues, Vision, Rhythms, Relationships, Responsibilities, Rituals (defined in `ApplicationController::DASHBOARD_MODULES`)
- Admins can toggle which modules are visible to regular users via the admin dashboard
- Hidden modules stored in `session[:hidden_modules]` (no database migration needed)
- `visible_modules` helper returns array of currently visible module names
- Non-visible modules only shown to admins when not in "View as User" mode, with an "Admin Preview - Hidden from users" badge
- Controlled by `show_admin_features?` and `visible_modules` helpers in `ApplicationController`

### Simplified Forms
- **Member form** (`members/_form.html.erb`): shows name, birthdate (optional), age, role dropdown (Parent/Teen/Child), and email field (shown via Alpine.js for parent/teen roles). When birthdate is provided, age is auto-calculated and child/teen role is auto-assigned (13+ = teen, under 13 = child). Parent roles are never auto-assigned. Hidden fields (personality, interests, health, needs, development) remain in DB schema and strong params.
- **Member show page** (`members/show.html.erb`): MVP fields only — avatar, name, age, birthdate (if present), role (Parent/Child), edit/delete actions. Health, Interests, Needs, and Quarterly Assessments cards removed.
- **Member card** (`members/_member_card.html.erb`): shows "Parent" or "Child" role label for all members.
- **Member card with status** (`members/_member_card_with_status.html.erb`): shows member with status badge (You, Admin, Joined, Pending, Not Invited) and Invite/Resend buttons for eligible members.
- **Members index** (`members/index.html.erb`): groups members by role (Parents, Teens, Children) with status badges and invite actions. The admin parent appears in the Parents section with an "Admin" badge.
- **Issue form** (`issues/_form.html.erb`): shows only description and urgency. Hidden fields (list_type, member_ids, family_value_ids, issue_type, root_issue_id) remain in DB. `IssuesController` defaults `list_type` to "Family" and `issue_type` to "root" when not provided.
- **Vision show page** (`family_visions/show.html.erb`): empty state with "Start Building Your Vision" CTA when no vision data exists; populated state shows values tags, mission statement card, 10-year dream card, and last updated date.

### Admin "View as User" Toggle
- Admins can toggle a "View as User" mode via `session[:view_as_user]`
- Route: `POST /admin/toggle_view_as_user`
- When active, `show_admin_features?` returns false, hiding non-visible dashboard cards and showing an indigo banner
- Helper methods: `viewing_as_user?`, `show_admin_features?`, `visible_modules` (all exposed as `helper_method` in `ApplicationController`)

### Admin Module Visibility Toggle
- Admins can toggle individual dashboard modules on/off from the admin dashboard
- Route: `POST /admin/toggle_module_visibility` with `module_name` param
- Stores hidden modules in `session[:hidden_modules]` array
- `visible_modules` helper returns `DASHBOARD_MODULES - hidden_modules`
- Modules: Members, Issues, Vision, Rhythms, Relationships, Responsibilities, Rituals

## Things to Watch Out For

- **`current_family` helper** in `ApplicationController` still does an unscoped `Family.find_by` as a fallback. It's used in views (helper_method) but should not be trusted for authorization — always use `@family` set by `authorize_family!`.
- **Stripe price ID is hardcoded** in `BillingController#checkout`. Will need updating if the Stripe plan changes. Note: Stripe errors are now caught and show user-friendly messages.
- **Devise email sender** in `config/initializers/devise.rb` likely needs updating for production.
- **`IssueMember` model** has incorrect associations (`has_many :issue_members` and `has_many :issues, through: :issue_members` on a join model) — these are dead code but could cause confusion.
- **No test coverage for authorization**. The auth fixes (authenticate_user!, authorize_family!) don't have corresponding controller tests yet.
- **Alpine.js loaded via CDN** — no pinned version, could break on major update.
- **`FamiliesController#new`** doesn't `return` after the redirect when user already has a family, so `@family = Family.new` always runs.
- **JavaScript must use `javascript_importmap_tags`** in `application.html.erb`, not `javascript_include_tag`. The importmap helper is required for ES module `import` statements to work.
- **Stimulus reserved properties**: Don't use `this.data` in Stimulus controllers — it's a read-only property (DataMap for `data-*` attributes). Use a different name like `this.graphData` or `this._data`.

## Code Quality Notes

The following patterns are enforced throughout the codebase:

- **Authorization callbacks always return**: All `redirect_to` and `head` calls in `before_action` methods are followed by `return` to prevent action execution from continuing.
- **Transactions for multi-model updates**: `FamilyInvitationsController#accept` and `FamilyVisionsController#update` wrap related updates in `ActiveRecord::Base.transaction` to ensure atomicity.
- **N+1 prevention**: Index actions use `.includes()` for associations displayed in views:
  - `IssuesController#index`: `.includes(:members, :family_values)`
  - `MembersController#index`: `.includes(:user, :invitation)`
- **Stripe error handling**: `BillingController#checkout` rescues `Stripe::StripeError` and checks for family presence before creating checkout sessions.
- **JS cleanup**: Stimulus controllers remove dynamically created DOM elements (like tooltips) in `disconnect()` to prevent accumulation during Turbo navigation.

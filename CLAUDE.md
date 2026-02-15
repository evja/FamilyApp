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

## Production

- **Domain**: `www.myfamilyhub.com` (canonical host)
- **Canonical redirect**: `ApplicationController#enforce_canonical_host` redirects all production traffic to `www.myfamilyhub.com` via 301. Skips `/up` health check.
- **Allowed hosts**: Both `www.myfamilyhub.com` and `myfamilyhub.com` are configured in `production.rb`
- **Mailer host**: Uses `www.myfamilyhub.com` for email links

## Models & Relationships

```
User
  belongs_to :family (optional, legacy)
  belongs_to :current_family (optional, for multi-family)
  has_many :members (dependent: nullify)
  has_many :families, through: :members
  # Devise handles auth. Has admin flag. Last user destroys family on delete.
  # Onboarding: onboarding_state (pending, welcome, add_members, first_issue, dashboard_intro, complete)
  # Onboarding: onboarding_completed_at (timestamp when onboarding finished)
  # Signup code: signup_code (e.g., "beta26" for beta testers)
  # Methods: active_family, switch_family!(family), member_of?(family), member_in(family)
  # Methods: family_admin?, family_parent?, family_role (use active_family context)
  # Methods: onboarding_complete?, onboarding_pending?, in_onboarding?, advance_onboarding_to!(state), complete_onboarding!
  # Methods: signup_code_type, beta_tester?
  # Access methods (two-gate system):
  #   - bypasses_subscription? → true if admin, beta_tester, OR subscribed (can access paid features)
  #   - bypasses_progression? → true if admin only (can skip unlock sequence)
  #   - has_full_access? → alias for bypasses_subscription? (legacy)

Family
  has_many :users (dependent: nullify)
  has_many :current_family_users (User, foreign_key: :current_family_id, dependent: nullify)
  has_many :members (dependent: destroy)
  has_many :family_values (dependent: destroy)
  has_many :issues (dependent: destroy)
  has_many :invitations (FamilyInvitation, dependent: destroy)
  has_many :rhythms (dependent: destroy)
  has_many :relationships (dependent: destroy)
  has_many :maturity_levels (dependent: destroy)
  has_many :rituals (dependent: destroy)
  has_one  :vision (FamilyVision, dependent: destroy)
  includes Themeable concern (7 theme presets: forest, ocean, sunset, earth, olive, slate, rosegold)
  # Subscription: subscription_status (free, trial, active, past_due, canceled), stripe_subscription_id
  # Methods: owner_member, owner_user, subscribed?, can_be_accessed_by?(user)
  # Note: current_family_users association needed to nullify User.current_family_id before family deletion (FK constraint)

Member
  belongs_to :family
  belongs_to :user (optional)
  has_many :issues, through: :issue_members
  has_one :invitation (FamilyInvitation)
  has_many :thrive_assessments (dependent: destroy)
  # Represents a person in the family (name, age, birthdate, personality, interests, health, etc.)
  # Roles: admin_parent, parent, teen, child, advisor (ROLES constant)
  # Only admin_parent/parent/teen/advisor can have accounts (can_have_account?)
  # Advisor role: view-only access, cannot edit (can_edit? returns false)
  # Fields: role, email, birthdate, invited_at, joined_at
  # Scopes: admin_parents, invitable, pending_invitation, with_accounts
  # Birthdate: Optional. When set, age is auto-calculated and child/teen role is auto-assigned (TEEN_AGE_THRESHOLD = 13)
  # Methods: calculated_age, role_for_age(age), can_edit?, advisor?

Issue
  belongs_to :family
  belongs_to :root_issue (self-referential, optional)
  has_many :symptom_issues (self-referential via root_issue_id)
  has_many :members, through: :issue_members
  has_many :family_values, through: :issue_values
  # Types: "root" or "symptom". Urgency: Low/Medium/High.
  # List types: family, parent, individual (LIST_TYPES constant, lowercase)
  # Status flow: new → acknowledged → working_on_it → resolved
  # Scopes: active, resolved, resolved_this_week, visible_to(user), for_list_type(type)
  # Visibility: family=all users, parent=parents only, individual=tagged members+parents
  # Methods: tagged_members, list_type_label, next_status, advance_status!

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

MaturityLevel
  belongs_to :family
  has_many :behaviors (MaturityBehavior, dependent: destroy)
  has_many :privileges (MaturityPrivilege, dependent: destroy)
  # Age-based maturity levels for children (Yellow 3-6, Orange 7-8, etc.)
  # Fields: name, color_code, age_min, age_max, position, description
  # Scopes: ordered
  # Methods: color_name, age_range_label, behaviors_by_category, privileges_by_category
  # Auto-seeded via MaturityChartSeeder service

MaturityBehavior
  belongs_to :maturity_level
  # Expected behaviors at each maturity level
  # CATEGORIES: body, things, clothing, responsibilities, emotions
  # Fields: category, description, position
  # Scopes: ordered, by_category

MaturityPrivilege
  belongs_to :maturity_level
  # Privileges earned at each maturity level
  # CATEGORIES: money, bedtime, screen_time, food, social, independence
  # Fields: category, description, value, position
  # Scopes: ordered, by_category

Ritual
  belongs_to :family
  has_many :components (RitualComponent, dependent: destroy)
  has_many :ritual_values (dependent: destroy)
  has_many :family_values, through: :ritual_values
  # Meaningful family traditions
  # RITUAL_TYPES: connection, special_person, community, coming_of_age, celebration
  # FREQUENCIES: daily, weekly, monthly, yearly, milestone
  # Fields: name, description, ritual_type, frequency, purpose, is_active, position
  # Scopes: active, inactive, by_type, ordered
  # Methods: ritual_type_label, frequency_label, total_duration_minutes, duration_display

RitualComponent
  belongs_to :ritual
  # Steps within a ritual
  # COMPONENT_TYPES: prepare, begin, perform, end
  # Fields: component_type, title, description, duration_minutes, position
  # Scopes: ordered, by_type

RitualValue
  belongs_to :ritual
  belongs_to :family_value
  # Join table linking rituals to family values

Join tables: IssueMember, IssueValue, IssueAssist, RitualValue
```

## Route Structure

All family resources are nested under `/families/:family_id/`:
- `/families/:family_id/members` (+ member routes `invite`, `resend_invite`)
- `/families/:family_id/issues` (+ collection route `solve`, member route `advance_status`)
- `/families/:family_id/issue_assists` (POST only — AI writing assistant)
- `/families/:family_id/family_invitations`
- `/families/:family_id/vision` (singular resource with `assist` action for AI suggestions)
- `/families/:family_id/rhythms` (+ collection routes `setup`, `update_setup`, `templates`; member routes `start`, `run`, `check_item`, `uncheck_item`, `finish`, `skip`)
- `/families/:family_id/rhythms/:rhythm_id/agenda_items` (CRUD for agenda items)
- `/families/:family_id/maturity_levels` (view-only maturity chart)
- `/families/:family_id/rituals` (CRUD for family rituals)
- `/families/:family_id/relationships` (+ collection route `graph_data`; member routes `assess`, `create_assessment`)
- `/families/:id/switch` (POST — switch user's current family for multi-family support)

Other routes:
- `/` — landing page (redirects to family if logged in)
- `/about` — static page
- `/leads` — lead capture POST
- `/onboarding` — 4-step onboarding wizard (GET show, PATCH update, POST complete, POST skip)
- `/invitations/:token/accept` — invitation acceptance
- `/billing/checkout` (POST) — Stripe checkout session creation
- `/admin/dashboard` and `/admin/leads` — admin area
- `/admin/toggle_view_as_user` — toggle "View as User" mode
- `/admin/toggle_module_visibility` — toggle dashboard module visibility

## Authorization Pattern

All family-scoped controllers use this pattern (defined in `ApplicationController`):

1. `before_action :authenticate_user!` — Devise login gate
2. `before_action :authorize_family!` — finds family by `params[:family_id]`, checks `current_user.member_of?(@family)`, rejects if not a member

`FamiliesController` has its own `set_family` that does the same thing but checks `params[:id]` instead of `params[:family_id]`.

`FamilyInvitationsController` uses its own `ensure_family_member` check that calls `family.can_be_accessed_by?(user)`.

**Multi-Family Authorization**: With multi-family support, authorization checks use `member_of?` instead of comparing family IDs. A user can be a member of multiple families through their Member records.

**RoleAuthorization Concern** (`app/controllers/concerns/role_authorization.rb`):
- `current_member` helper — returns the Member record for current user in the current family (`member_in(@family)`)
- `require_parent_access!` — checks if user has parent or admin_parent role
- `require_admin_access!` — checks if user is the family admin
- `require_edit_access!` — checks `current_member.can_edit?` (advisors are view-only)

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
- **Dashboard Layout**: Clean 6-card module grid ordered by progression: Issues → Relationships → Rhythms → Vision → Responsibilities → Rituals (matches Stabilize → Orient → Operate tiers). Members card removed - access via navbar dropdown instead. First Rhythm Banner shows for parents who have completed onboarding but have no rhythms yet, prompting them to set up a Weekly Parent Sync. `FamiliesController#show` sets `@show_first_rhythm_prompt` based on: `current_user.onboarding_complete? && !@has_any_rhythms && current_member.parent_or_above?`.
- **Dashboard stats**: Issues card shows "X open · Y resolved this week" counts from `@open_issue_count` and `@resolved_this_week_count` set in `FamiliesController#show`.
- **Rhythms module**: Recurring family meetings with customizable agendas. Rhythms have frequency settings (daily to annually) and categories (parent_sync, family_huddle, retreat, check_in, custom). Each rhythm has agenda items with optional links to other sections (issues, vision, members, thrive). Meeting flow: start → check items → finish. Progress is tracked via `RhythmCompletion` and `CompletionItem` records. Turbo Streams update both checkbox items and the actions section (`_rhythm_actions.html.erb` partial) so the "Complete Meeting" button enables when all items are checked.
- **Agenda Items**: Managed via `AgendaItemsController` nested under rhythms. Each item has title, instructions, duration, position, and optional link type. Items are displayed in order during meeting runs. CRUD available from rhythm edit page.
- **Thrive Assessments**: Child/teen wellness check-ins with 4 dimensions (mind, body, spirit, responsibility) rated 1-5. Assessments are immutable after creation. Can be linked to a `RhythmCompletion` when done during a retreat. Only members with role `child` or `teen` can have assessments.
- **Relationships module**: Tracks relationships between all pairs of family members. `Family#ensure_all_relationships!` auto-creates missing pairs. Each relationship can be assessed with cooperation/affection/trust scores (0-2 each, 6 total). Health bands: high (5-6), functioning (3-4), low (0-2). Relationship graph uses D3 force simulation with responsive sizing (68vh, min 510px). Bubbles scale proportionally with container while preserving age-based size ratios. Initial layout arranges family in a ring: parents at top, children clockwise by age (youngest near first parent, oldest near second). Click a node to enter focus mode (centers node, fades unrelated links), ESC or click background to reset. Click lines to assess relationships.
- **Issue creation points**: Issues can be created from multiple contexts with prefill and return-to-context:
  - Issues index: standard creation
  - Member show page: "+ Issue" button pre-tags the member, sets list_type to individual
  - Rhythm run page: "Log Issue" button prefills description with rhythm name, returns to running meeting
  - Relationship assess page: "Create Issue" link pre-tags both members, sets list_type to individual
- **Progressive module unlock**: Dashboard modules unlock sequentially as families complete setup steps. Card order: Issues → Relationships → Rhythms → Vision → Responsibilities → Rituals (matches Stabilize → Orient → Operate progression). Two-level access: progression lock + subscription lock. See "Progressive Module Unlock System" section under MVP Simplification for details.
- **Multi-Family Support**: Users can belong to multiple families through Member records. `User#active_family` returns current_family or first family. Switch families via `POST /families/:id/switch`. Navbar shows family switcher dropdown when user has 2+ families. Each family has its own `subscription_status`. Invitations now allow joining additional families.
- **Navbar Layout**: Desktop navbar includes: Dashboard link, Members dropdown (shows all family members with avatars, "+ Add" button, "Manage members" link), Help link, Settings icon (gear), and Subscribe button (for non-subscribers). Mobile menu has equivalent links. The family dropdown (left side) includes: family switcher (if multi-family), Settings link, Create New Family, and Log Out.
- **Consolidated Settings Page** (`devise/registrations/edit.html.erb`): Single page combining Family Settings (name, theme) and Account Settings (email, password). Family Settings section only shows if user has an active family. Danger Zone at bottom includes Delete Family (for family admins) and Delete Account options with typed confirmation modals.
- **Onboarding Wizard**: 4-step behavior-driven onboarding for new users. Steps: Welcome (create family) → Add Members ("Who else is in your family?" - user is already set up as parent) → First Issue → Dashboard Intro. Uses `layout 'onboarding'` (minimal layout with progress bar). State machine on User model (`onboarding_state` field). New signups start at `pending`, advance through steps, end at `complete`. `ApplicationController#redirect_to_onboarding` before_action redirects incomplete users. Exempt controllers: onboardings, devise/*, family_invitations, families, members, issues. Invitation acceptees skip onboarding entirely (state set to `complete` in `FamilyInvitationsController#accept`). Micro-celebrations: confetti on dashboard intro, toast notifications on member/issue creation. Skip link available on all steps. Dashboard Intro step includes prominent "Parent Sync" recommendation.
- **Safe Delete Confirmation**: Destructive actions (delete member, delete family, delete user account) require typed confirmation. Uses `confirm_delete_controller.js` Stimulus controller. User must type exact phrase (e.g., "Delete John") to enable delete button. Shows cascade warning of what will be deleted. ESC or backdrop click closes modal. Reusable pattern: wrap button + modal in same `data-controller="confirm-delete"` scope. Delete buttons are located on edit pages: member delete in `members/edit.html.erb`, family delete in `families/edit.html.erb`.
- **Shared UI Partials**: Reusable view components in `app/views/shared/`:
  - `_back_link.html.erb` — Standard back navigation link. Params: `path` (required), `text` (default: "Back to Dashboard").
  - `_page_header.html.erb` — Page header with title, back link, and optional actions. Params: `title`, `back_path` (required), `back_text`, `subtitle`. Use `content_for :page_actions` for action buttons.
  - `_empty_state.html.erb` — Empty state with icon, headline, description, and CTA. Params: `title`, `description`, `action_path`, `action_text` (required), `icon`, `examples`, `examples_label`.
  - `_confirm_delete_modal.html.erb` — Typed confirmation modal for destructive actions. See Safe Delete Confirmation above.
- **Dashboard Partials** (`app/views/families/`):
  - `_first_rhythm_banner.html.erb` — Prompts parents to start their first Parent Sync meeting. Shows when `@show_first_rhythm_prompt` is true (onboarding complete, no rhythms, user is parent). Links to rhythm setup with "Weekly Parent Sync" template pre-selected.
- **Button Classes**: Standardized button classes in `theme_plugin.js`:
  - `btn-primary` — Main action buttons (uses `--primary-color` CSS variable)
  - `btn-secondary` — Outline style with theme color border
  - `btn-danger` — Red destructive action buttons (for modals)
  - `btn-danger-text` — Red text links for destructive actions
  - Legacy classes (`theme-button-filled`, `theme-button-outline`) still work but prefer new `btn-*` classes for new code.

## MVP Simplification

The app has been simplified for MVP launch. Fields and features are hidden from the UI but preserved in the database for future use.

### Dashboard Card Visibility
- **Dashboard modules** (ordered by progression): Issues → Relationships → Rhythms → Vision → Responsibilities → Rituals (6 cards in grid)
- **Card order rationale**: Matches Stabilize → Orient → Operate transformation tiers
- **Members**: Accessed via navbar dropdown, not in dashboard grid
- **Two-Gate Access System** (`families/show.html.erb`):
  - **Gate 1: Progression** — Must complete unlock steps (add members → create issue → complete rhythm → etc.)
  - **Gate 2: Subscription** — Must be admin, beta tester, or paid subscriber
  - Access formula: `is_available = bypasses_progression || (is_unlocked && (is_free_module || bypasses_subscription))`
- **User Type Behavior**:

  | User Type | `bypasses_subscription?` | `bypasses_progression?` | Experience |
  |-----------|-------------------------|------------------------|------------|
  | Admin | ✅ | ✅ | All modules unlocked immediately |
  | Beta Tester | ✅ | ❌ | Sees progression locks (can test flow), NO subscription locks |
  | Subscriber | ✅ | ❌ | Same as beta tester |
  | Free User | ❌ | ❌ | Sees both progression AND subscription locks |

- **Lock Badge Display**:
  - **Progression lock**: Gray lock icon, "Complete steps to unlock" badge
  - **Subscription lock**: Themed lock icon, "Subscribe to unlock" badge
- **Next Step Banner**: Shows when `!bypasses_progression? && next_unlockable_module.present?` (beta testers see it, admins don't)
- All 6 modules always visible on dashboard (never hidden), just locked appropriately

### Simplified Forms
- **Member form** (`members/_form.html.erb`): shows name, birthdate (optional), age, role dropdown (Parent/Teen/Child), and email field (shown via Alpine.js for parent/teen roles). When birthdate is provided, age is auto-calculated and child/teen role is auto-assigned (13+ = teen, under 13 = child). Parent roles are never auto-assigned. Hidden fields (personality, interests, health, needs, development) remain in DB schema and strong params.
- **Member show page** (`members/show.html.erb`): MVP fields only — avatar, name, age, birthdate (if present), role (Parent/Child), edit action. Health, Interests, Needs, and Quarterly Assessments cards removed. Delete action is on the edit page.
- **Member card** (`members/_member_card.html.erb`): shows "Parent" or "Child" role label for all members.
- **Member card with status** (`members/_member_card_with_status.html.erb`): shows member with status badge (You, Admin, Joined, Pending, Not Invited) and Invite/Resend buttons for eligible members.
- **Members index** (`members/index.html.erb`): groups members by role (Parents, Teens, Children) with status badges and invite actions. The admin parent appears in the Parents section with an "Admin" badge.
- **Issue form** (`issues/_form.html.erb`): shows description, urgency, visibility selector (family/parent/individual), and member tagging checkboxes. Supports prefill via query params (`prefill_description`, `list_type`, `member_ids[]`) and return-to-context via `return_to` param. `IssuesController` defaults `list_type` to "family" and `issue_type` to "root" when not provided.
- **Issues index** (`issues/index.html.erb`): filter tabs (All/Family/Parents/Individual) with counts, list type badges, and tagged member avatars on cards. Parent tab hidden from non-parent users.
- **Vision show page** (`family_visions/show.html.erb`): empty state with "Start Building Your Vision" CTA when no vision data exists; populated state shows values tags, mission statement card, 10-year dream card, and last updated date.

### Admin "View as User" Toggle
- Admins can toggle a "View as User" mode via `session[:view_as_user]`
- Route: `POST /admin/toggle_view_as_user`
- When active, `show_admin_features?` returns false and shows an indigo banner
- Helper methods: `viewing_as_user?`, `show_admin_features?` (exposed as `helper_method` in `ApplicationController`)

### Progressive Module Unlock System

New families are guided through FamilyHub with a linear unlock path to prevent overwhelm. Modules unlock progressively based on the Family Operating System's transformation tiers.

**Design Intent**: Rather than showing all 7 modules at once (which can overwhelm new users), the system reveals features as families progress through transformation tiers. This creates a natural flow: stabilize (capture issues) → orient (establish rhythms) → operate (define vision).

**Transformation Tiers**:
- **Stabilize** (Plug the holes): Members + Issues
- **Orient** (Organize the ship): Rhythms + Relationships
- **Operate** (Set sail): Vision + Responsibilities + Rituals

**Unlock Order & Conditions**:

| Module | Unlock Condition | Tier |
|--------|------------------|------|
| Members | Always unlocked | Stabilize |
| Issues | 1+ members beyond admin | Stabilize |
| Relationships | 1+ members beyond admin | Orient |
| Rhythms | Issues unlocked AND 1+ issue exists | Orient |
| Vision | 1+ rhythm completed | Operate |
| Responsibilities | Vision complete (mission_statement 10+ chars) | Operate |
| Rituals | Vision complete (mission_statement 10+ chars) | Operate |

**Helper Methods** (`app/helpers/application_helper.rb`):
- `module_unlocked?(module_name)` — checks if a module is accessible based on family state
- `vision_complete?` — returns true if mission_statement exists and is 10+ characters
- `next_unlockable_module` — returns the next module in the unlock sequence (or nil if all unlocked)
- `module_unlock_message(module_name)` — motivational message for the module
- `module_unlock_condition(module_name)` — human-readable unlock requirement
- `module_unlock_progress(module_name)` — returns progress data (numeric, boolean, or blocked)

**Dashboard Behavior** (`families/show.html.erb`):
- **Card Order**: Issues → Relationships → Rhythms → Vision → Responsibilities → Rituals (matches progression)
- **Access Logic** (two-gate system):
  ```
  bypasses_progression = current_user.bypasses_progression?  # admin only
  bypasses_subscription = current_user.bypasses_subscription?  # admin, beta, subscriber
  is_available = bypasses_progression || (is_unlocked && (is_free_module || bypasses_subscription))
  progression_locked = !bypasses_progression && !is_unlocked
  subscription_locked = !bypasses_subscription && is_unlocked && !is_free_module
  ```
  - **Admin**: bypasses both gates → all modules available immediately
  - **Beta/Subscriber**: bypasses subscription only → must progress through unlock sequence, but no payment gate
  - **Free user**: blocked by both gates → must progress AND subscribe
  - Progression-locked modules show gray "Complete steps to unlock" badge
  - Subscription-locked modules show themed "Subscribe to unlock" badge
- **Next Step Banner**: Shows when `!bypasses_progression? && next_unlockable_module.present?` (beta testers see this)
- **All Unlocked Celebration**: Green banner when all modules are unlocked (for users who progress)
- All 6 modules always visible on dashboard, just locked appropriately

**Cross-Module Link Protection**: Issue creation buttons are conditionally hidden until Issues module is unlocked:
- `members/show.html.erb`: "+ Issue" button wrapped in `module_unlocked?(:issues)` check
- `rhythms/run.html.erb`: "Log Issue" button wrapped in `module_unlocked?(:issues)` check
- `relationships/assess.html.erb`: "Create Issue" link wrapped in `module_unlocked?(:issues)` check

**No Database Changes**: Unlock state is purely derived from existing family data (members count, issues count, rhythm completions, vision presence). Existing families automatically have their correct unlock state calculated.

**Tests**: `test/helpers/application_helper_test.rb` covers all unlock logic.

### Signup Codes & Beta Access

Users can enter a signup code during registration to get special access:

**Valid Codes** (defined in `User::VALID_SIGNUP_CODES`):
- `beta26`, `betatester`, `familyhub2026` → Beta tester access

**Two-Gate Access System**:
The app separates two concerns to allow beta testers to experience the real user flow:
1. **`bypasses_subscription?`** — Can access paid features without paying (admin, beta, subscriber)
2. **`bypasses_progression?`** — Can skip the progressive unlock sequence (admin only)

**Why This Matters**:
- Beta testers need to TEST the progression flow, not skip it
- They should see "Complete steps to unlock" badges as they progress
- They should NOT see "Subscribe to unlock" badges (they're testing for free)
- Admins bypass everything for debugging/support purposes

**User Model Methods**:
- `signup_code_type` → returns `:beta_tester` or `nil` based on code
- `beta_tester?` → true if user signed up with a beta tester code
- `bypasses_subscription?` → true if admin, beta_tester, or is_subscribed
- `bypasses_progression?` → true if admin only
- `has_full_access?` → alias for `bypasses_subscription?` (legacy compatibility)

**Registration Form**: `devise/registrations/new.html.erb` includes optional "Access Code" field. Permitted via `configure_permitted_parameters` in ApplicationController.

## Things to Watch Out For

- **`current_family` helper** in `ApplicationController` does an unscoped `Family.find_by` then falls back to `current_user.active_family`. It's used in views (helper_method) but should not be trusted for authorization — always use `@family` set by `authorize_family!`.
- **Stripe price ID is hardcoded** in `BillingController#checkout`. Will need updating if the Stripe plan changes. Note: Stripe errors are now caught and show user-friendly messages.
- **Devise email sender** in `config/initializers/devise.rb` likely needs updating for production.
- **`IssueMember` model** has incorrect associations (`has_many :issue_members` and `has_many :issues, through: :issue_members` on a join model) — these are dead code but could cause confusion.
- **No test coverage for authorization**. The auth fixes (authenticate_user!, authorize_family!) don't have corresponding controller tests yet.
- **Alpine.js loaded via CDN** — pinned to `@3.14.0` in both `application.html.erb` and `onboarding.html.erb`.
- **`FamiliesController#new`** now allows creating additional families (multi-family support). No longer redirects if user has a family.
- **JavaScript must use `javascript_importmap_tags`** in `application.html.erb`, not `javascript_include_tag`. The importmap helper is required for ES module `import` statements to work.
- **Stimulus reserved properties**: Don't use `this.data` in Stimulus controllers — it's a read-only property (DataMap for `data-*` attributes). Use a different name like `this.graphData` or `this._data`.
- **Stimulus controller scope**: When using `data-action` to call a Stimulus controller method, the element with `data-action` must be a descendant of the element with `data-controller`. For the confirm-delete pattern, the button and modal must both be inside the same `data-controller="confirm-delete"` wrapper.

## Code Quality Notes

The following patterns are enforced throughout the codebase:

- **Authorization callbacks always return**: All `redirect_to` and `head` calls in `before_action` methods are followed by `return` to prevent action execution from continuing.
- **Transactions for multi-model updates**: `FamilyInvitationsController#accept` and `FamilyVisionsController#update` wrap related updates in `ActiveRecord::Base.transaction` to ensure atomicity.
- **N+1 prevention**: Index actions use `.includes()` for associations displayed in views:
  - `IssuesController#index`: `.includes(:members, :family_values)`
  - `MembersController#index`: `.includes(:user, :invitation)`
- **Stripe error handling**: `BillingController#checkout` rescues `Stripe::StripeError` and checks for family presence before creating checkout sessions.
- **JS cleanup**: Stimulus controllers remove dynamically created DOM elements (like tooltips) in `disconnect()` to prevent accumulation during Turbo navigation.

class OnboardingsController < ApplicationController
  include OnboardingsHelper

  before_action :authenticate_user!
  before_action :redirect_if_complete, except: [:complete, :skip]
  before_action :set_progress

  layout 'onboarding'

  def show
    # Start at welcome if pending
    if current_user.onboarding_pending?
      current_user.advance_onboarding_to!('welcome')
    end

    @state = current_user.onboarding_state
    @family = current_user.active_family

    case @state
    when 'welcome'
      render :welcome
    when 'add_members'
      @family = current_user.active_family
      @members = @family.members.where.not(role: 'admin_parent').order(:created_at)
      @member = @family.members.new
      render :add_members
    when 'first_issue'
      @family = current_user.active_family
      @issue = @family.issues.new(list_type: 'family')
      @members = @family.members.order(:name)
      render :first_issue
    when 'dashboard_intro'
      @family = current_user.active_family
      render :dashboard_intro
    else
      redirect_to family_path(current_user.active_family)
    end
  end

  def update
    @state = current_user.onboarding_state

    case @state
    when 'welcome'
      handle_welcome_step
    when 'add_members'
      handle_add_members_step
    when 'first_issue'
      handle_first_issue_step
    when 'dashboard_intro'
      handle_dashboard_intro_step
    else
      redirect_to onboarding_path
    end
  end

  def complete
    current_user.complete_onboarding!
    redirect_to family_path(current_user.active_family), notice: "Welcome to FamilyHub!"
  end

  def skip
    current_user.complete_onboarding!
    if current_user.active_family
      redirect_to family_path(current_user.active_family), notice: "You can set up your family anytime from the dashboard."
    else
      redirect_to new_family_path, notice: "Let's create your family first."
    end
  end

  private

  def redirect_if_complete
    if current_user.onboarding_complete?
      redirect_to current_user.active_family ? family_path(current_user.active_family) : new_family_path
    end
  end

  def set_progress
    @progress_percentage = onboarding_progress_percentage(current_user.onboarding_state)
  end

  def handle_welcome_step
    family_name = params[:family_name]&.strip

    if family_name.blank?
      flash.now[:alert] = "Please enter a family name"
      @state = 'welcome'
      @progress_percentage = onboarding_progress_percentage(@state)
      render :welcome, status: :unprocessable_entity
      return
    end

    # Create the family
    family = Family.new(name: family_name)

    if family.save
      # Create the admin_parent member for current user
      member = family.members.create!(
        name: current_user.email.split('@').first.titleize,
        role: 'admin_parent',
        email: current_user.email,
        user: current_user,
        joined_at: Time.current
      )

      # Link user to family
      current_user.update!(family: family, current_family: family)

      # Advance to next step
      current_user.advance_onboarding_to!('add_members')
      redirect_to onboarding_path, notice: "Family created! Now let's add your family members."
    else
      flash.now[:alert] = family.errors.full_messages.join(', ')
      @state = 'welcome'
      @progress_percentage = onboarding_progress_percentage(@state)
      render :welcome, status: :unprocessable_entity
    end
  end

  def handle_add_members_step
    # User chose to continue, advance to first_issue
    current_user.advance_onboarding_to!('first_issue')
    redirect_to onboarding_path
  end

  def handle_first_issue_step
    # User chose to continue without creating issue, advance to dashboard_intro
    current_user.advance_onboarding_to!('dashboard_intro')
    redirect_to onboarding_path
  end

  def handle_dashboard_intro_step
    current_user.complete_onboarding!
    redirect_to family_path(current_user.active_family), notice: "You're all set! Welcome to FamilyHub."
  end
end

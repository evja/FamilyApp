class FamiliesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to family_path(current_user.family) if current_user.family
  end

  def show
    redirect_to new_family_path unless @family
    return unless @family

    @open_issue_count = @family.issues.active.count
    @resolved_this_week_count = @family.issues.resolved_this_week.count
    @has_any_issues = @family.issues.exists?

    # Badge counts for dashboard cards
    @issues_needing_attention = @open_issue_count
    @vision_incomplete_count = calculate_vision_incomplete_count
    @pending_invites_count = @family.members.where.not(invited_at: nil).where(user_id: nil).count

    # Rhythms
    @overdue_rhythms_count = @family.rhythms.overdue.count
    @has_any_rhythms = @family.rhythms.exists?

    # Future badges (prep for later)
    @overdue_responsibilities_count = 0
    @relationships_needing_attention_count = 0
    @upcoming_rituals_count = 0
  end

  def new
    return redirect_to family_path(current_user.family) if current_user.family
    @family = Family.new
  end

  def edit
  end

  def create
    @family = Family.new(family_params)

    if @family.save
      current_user.update(family: @family)
      @family.ensure_admin_parent_member(current_user)
      redirect_to @family, notice: 'Family was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @family.update(family_params)
      redirect_to @family, notice: 'Family was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @family.users.count > 1
      redirect_to @family, alert: 'Cannot delete family while other users are still members.'
    else
      @family.destroy
      redirect_to root_path, notice: 'Family was successfully deleted.'
    end
  end

  private

  def set_family
    @family = current_user.family
    unless @family && @family.id == params[:id].to_i
      redirect_to root_path, alert: 'You do not have access to this family.'
    end
  end

  def family_params
    params.require(:family).permit(:name, :theme)
  end

  def calculate_vision_incomplete_count
    vision = @family.vision
    return 3 if vision.nil?

    count = 0
    count += 1 if vision.mission_statement.blank?
    count += 1 if vision.ten_year_dream.blank?
    count += 1 if @family.family_values.empty?
    count
  end
end

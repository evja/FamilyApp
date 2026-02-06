class IssuesController < ApplicationController
  include RoleAuthorization

  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :require_parent_access!, only: [:new, :create, :edit, :update, :destroy]

  def new
    @issue = @family.issues.new(list_type: "family")
    @members = @family.members.order(:name)
    @values = @family.family_values
    @root_issues = @family.issues.where(issue_type: "root")
    @assist_remaining = IssueAssist.remaining_today(@family)

    # Prefill from context
    @issue.description = params[:prefill_description] if params[:prefill_description].present?
    @issue.list_type = params[:list_type] if params[:list_type].present? && Issue::LIST_TYPES.include?(params[:list_type])

    # Pre-tag members from params
    if params[:member_ids].present?
      member_ids = Array(params[:member_ids]).map(&:to_i)
      @issue.member_ids = member_ids
    end

    @return_to = params[:return_to]
    @modal_mode = params[:modal] == "true"
  end

  def create
    @issue = @family.issues.new(issue_params)
    @issue.list_type = (@issue.list_type.presence || "family").downcase
    @issue.issue_type ||= "root"
    @issue.status ||= "new"

    if @issue.save
      return_path = params[:return_to].presence || family_issues_path(@family)
      redirect_to return_path, notice: "Issue captured successfully."
    else
      @members = @family.members.order(:name)
      @values = @family.family_values
      @root_issues = @family.issues.where(issue_type: "root")
      @assist_remaining = IssueAssist.remaining_today(@family)
      @return_to = params[:return_to]
      @modal_mode = params[:modal] == "true"
      render :new, status: :unprocessable_entity
    end
  end

  def index
    base_issues = @family.issues.visible_to(current_user)

    @list_filter = params[:list]
    filtered_issues = @list_filter.present? && Issue::LIST_TYPES.include?(@list_filter) ? base_issues.where(list_type: @list_filter) : base_issues

    @active_issues = filtered_issues.active.includes(:members, :family_values).order(created_at: :desc)
    @resolved_issues = filtered_issues.resolved.includes(:members, :family_values).order(resolved_at: :desc)
    @has_any_issues = @family.issues.visible_to(current_user).exists?

    # Counts for tabs
    @counts = {
      all: base_issues.active.count,
      family: base_issues.where(list_type: "family").active.count,
      parent: base_issues.where(list_type: "parent").active.count,
      individual: base_issues.where(list_type: "individual").active.count
    }
  end

  def show
    @issue = @family.issues.find(params[:id])
    @symptoms = @issue.symptom_issues if @issue.issue_type == "root"
  end

  def edit
    @issue = @family.issues.find(params[:id])
    @members = @family.members.order(:name)
    @values = @family.family_values
    @root_issues = @family.issues.where(issue_type: "root").where.not(id: @issue.id)
    @assist_remaining = IssueAssist.remaining_today(@family)
  end

  def update
    @issue = @family.issues.find(params[:id])

    update_attrs = issue_params
    update_attrs[:list_type] ||= @issue.list_type || "family"
    update_attrs[:issue_type] ||= @issue.issue_type || "root"

    if @issue.update(update_attrs)
      redirect_to family_issue_path(@family, @issue), notice: "Issue updated successfully."
    else
      @members = @family.members
      @values = @family.family_values
      @root_issues = @family.issues.where(issue_type: "root").where.not(id: @issue.id)
      @assist_remaining = IssueAssist.remaining_today(@family)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @issue = @family.issues.find(params[:id])
    @issue.destroy
    redirect_to family_issues_path(@family), notice: "Issue deleted."
  end

  def solve
    if params[:issue_ids].present?
      session[:solve_issue_ids] = params[:issue_ids].map(&:to_i)
    end
    @solve_issue_ids = session[:solve_issue_ids] || []
    @issues_to_solve = @family.issues.where(id: @solve_issue_ids)
    @current_issue = @issues_to_solve.first
  end

  def advance_status
    @issue = @family.issues.find(params[:id])
    if @issue.advance_status!
      redirect_back fallback_location: family_issues_path(@family), notice: "Issue moved to \"#{Issue::STATUS_LABELS[@issue.status]}\"."
    else
      redirect_back fallback_location: family_issues_path(@family), alert: "Issue is already resolved."
    end
  end

  private

  def issue_params
    params.require(:issue).permit(
      :description, :list_type, :urgency, :issue_type, :root_issue_id,
      member_ids: []
    )
  end
end

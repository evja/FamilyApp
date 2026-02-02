class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!

  def new
    @issue = @family.issues.new
    @members = @family.members
    @values = @family.family_values
    @root_issues = @family.issues.where(issue_type: "root")
    @assist_remaining = IssueAssist.remaining_today(@family)
  end

  def create
    @issue = @family.issues.new(issue_params)
    @issue.list_type ||= "Family"
    @issue.issue_type ||= "root"
    @issue.status ||= "new"

    if @issue.save
      redirect_to family_issues_path(@family), notice: "Issue added as an opportunity for growth."
    else
      @members = @family.members
      @values = @family.family_values
      @root_issues = @family.issues.where(issue_type: "root")
      @assist_remaining = IssueAssist.remaining_today(@family)
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @active_issues = @family.issues.active.includes(:members, :family_values, :root_issue).order(created_at: :desc)
    @resolved_issues = @family.issues.resolved.includes(:members, :family_values, :root_issue).order(resolved_at: :desc)
    @has_any_issues = @family.issues.exists?
  end

  def show
    @issue = @family.issues.find(params[:id])
    @symptoms = @issue.symptom_issues if @issue.issue_type == "root"
  end

  def edit
    @issue = @family.issues.find(params[:id])
    @members = @family.members
    @values = @family.family_values
    @root_issues = @family.issues.where(issue_type: "root").where.not(id: @issue.id)
    @assist_remaining = IssueAssist.remaining_today(@family)
  end

  def update
    @issue = @family.issues.find(params[:id])

    update_attrs = issue_params
    update_attrs[:list_type] ||= @issue.list_type || "Family"
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
      :description, :list_type, :urgency, :issue_type, :root_issue_id
    )
  end
end

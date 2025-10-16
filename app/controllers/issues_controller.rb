class IssuesController < ApplicationController

  def new
    @family = Family.find(params[:family_id])
    @issue = current_user.family.issues.new
    @members = current_user.family.members
    @values = current_user.family.family_values
    @root_issues = current_user.family.issues.where(issue_type: "root")
  end

  def create
    @family = Family.find(params[:family_id])
    @issue = current_user.family.issues.new(issue_params)

    if @issue.save
      @issue.member_ids = params[:issue][:member_ids] #.reject(&:blank?)
      @issue.family_value_ids = params[:issue][:family_value_ids]#.reject(&:blank?)
      redirect_to family_issues_path(current_user.family), notice: "Issue added as an opportunity for growth."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @family = Family.find(params[:family_id])
    @issues = current_user.family.issues.includes(:members, :family_values, :root_issue)
    @lists = ["Family", "Marriage", "Personal"]
    @urgencies = ["Low", "Medium", "High"]
    @types = ["root", "symptom"]
  end

  def show
    @family = Family.find(params[:family_id])
    @issue = @family.issues.find(params[:id])

    @symptoms = @issue.symptom_issues if @issue.issue_type == "root"
  end

  def edit
    @family = Family.find(params[:family_id])
    @issue = @family.issues.find(params[:id])
    @members = @family.members
    @values = @family.family_values
    @root_issues = @family.issues.where(issue_type: "root").where.not(id: @issue.id)
  end

  def update
    @family = Family.find(params[:family_id])
    @issue = @family.issues.find(params[:id])

    if @issue.update(issue_params)
      @issue.member_ids = params[:issue][:member_ids]#.reject(&:blank?)
      @issue.family_value_ids = params[:issue][:family_value_ids]#.reject(&:blank?)
      redirect_to family_issue_path(@family, @issue), notice: "Issue updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @family = Family.find(params[:family_id])
    @issue = @family.issues.find(params[:id])
    @issue.destroy
    redirect_to family_issues_path(@family), notice: "Issue deleted."
  end

  def solve
    @family = Family.find(params[:family_id])
    if params[:issue_ids].present?
      session[:solve_issue_ids] = params[:issue_ids].map(&:to_i)
    end
    @solve_issue_ids = session[:solve_issue_ids] || []
    @issues_to_solve = current_user.family.issues.where(id: @solve_issue_ids)
    @current_issue = @issues_to_solve.first
    # Render the wizard view for the first issue
  end

  private

  before_action :set_form_options, only: [:new, :edit]

  def set_form_options
    @members = current_user.family.members
    @values = current_user.family.family_values
    @root_issues = current_user.family.issues.where(issue_type: "root")
    @lists = ["Family", "Marriage", "Personal"]
    @urgencies = ["Low", "Medium", "High"]
    @types = ["root", "symptom"]
  end

  def issue_params
    params.require(:issue).permit(
      :description, :list_type, :urgency, :issue_type, :root_issue_id
    )
  end

end
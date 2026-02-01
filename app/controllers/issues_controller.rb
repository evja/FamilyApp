class IssuesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!

  def new
    @issue = @family.issues.new
    @members = @family.members
    @values = @family.family_values
    @root_issues = @family.issues.where(issue_type: "root")
  end

  def create
    @issue = @family.issues.new(issue_params)

    if @issue.save
      @issue.member_ids = params[:issue][:member_ids]
      @issue.family_value_ids = params[:issue][:family_value_ids]
      redirect_to family_issues_path(@family), notice: "Issue added as an opportunity for growth."
    else
      @members = @family.members
      @values = @family.family_values
      @root_issues = @family.issues.where(issue_type: "root")
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @issues = @family.issues.includes(:members, :family_values, :root_issue)
    @lists = ["Family", "Marriage", "Personal"]
    @urgencies = ["Low", "Medium", "High"]
    @types = ["root", "symptom"]
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
  end

  def update
    @issue = @family.issues.find(params[:id])

    if @issue.update(issue_params)
      @issue.member_ids = params[:issue][:member_ids]
      @issue.family_value_ids = params[:issue][:family_value_ids]
      redirect_to family_issue_path(@family, @issue), notice: "Issue updated successfully."
    else
      @members = @family.members
      @values = @family.family_values
      @root_issues = @family.issues.where(issue_type: "root").where.not(id: @issue.id)
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

  private

  def issue_params
    params.require(:issue).permit(
      :description, :list_type, :urgency, :issue_type, :root_issue_id
    )
  end
end

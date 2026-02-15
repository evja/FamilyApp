class MaturityLevelsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_maturity_level, only: [:show]

  def index
    # Seed default maturity chart if family doesn't have one
    MaturityChartSeeder.seed_for_family(@family) if @family.maturity_levels.empty?

    @maturity_levels = @family.maturity_levels.includes(:behaviors, :privileges).ordered
    @members = @family.members.order(:age)

    # Map members to their appropriate maturity level
    @members_by_level = {}
    @maturity_levels.each do |level|
      @members_by_level[level.id] = @members.select do |member|
        next false unless member.age.present?
        (level.age_min.nil? || member.age >= level.age_min) &&
        (level.age_max.nil? || member.age <= level.age_max)
      end
    end
  end

  def show
    @behaviors_by_category = @maturity_level.behaviors_by_category
    @privileges_by_category = @maturity_level.privileges_by_category

    # Members at this level
    @members_at_level = @family.members.select do |member|
      next false unless member.age.present?
      (@maturity_level.age_min.nil? || member.age >= @maturity_level.age_min) &&
      (@maturity_level.age_max.nil? || member.age <= @maturity_level.age_max)
    end
  end

  private

  def set_maturity_level
    @maturity_level = @family.maturity_levels.find(params[:id])
  end
end

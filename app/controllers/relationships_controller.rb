class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_relationship, only: [:show, :assess, :create_assessment]

  def index
    @family.ensure_all_relationships!
    @members = @family.members.order(:role, :name)
    @relationships = @family.relationships.includes(:member_low, :member_high)

    @total = @relationships.count
    @healthy_count = @relationships.healthy.count
    @needs_attention_count = @relationships.needs_attention.count
    @unassessed_count = @relationships.unassessed.count
  end

  def show
    @recent_assessments = @relationship.assessments.recent.limit(5)
  end

  def graph_data
    @family.ensure_all_relationships!

    render json: {
      members: @family.members.map { |m|
        { id: m.id, name: m.name, age: m.age, role: m.role,
          radius: m.bubble_radius, is_parent: m.parent_or_above?,
          color: m.display_color, avatar_emoji: m.avatar_emoji,
          display_name: m.display_name }
      },
      relationships: @family.relationships.includes(:assessments).map { |r|
        { id: r.id, source: r.member_low_id, target: r.member_high_id,
          health_score: r.current_health_score, health_band: r.current_health_band,
          health_color: r.health_color_hsl, display_name: r.display_name,
          assessed: r.assessed? }
      }
    }
  end

  def assess
    @assessment = @relationship.assessments.new
    @recent_assessments = @relationship.assessments.recent.limit(3)
  end

  def create_assessment
    @assessment = @relationship.assessments.new(assessment_params)
    @assessment.assessor = current_user

    if @assessment.save
      redirect_to family_relationships_path(@family), notice: "Assessment saved"
    else
      @recent_assessments = @relationship.assessments.recent.limit(3)
      render :assess, status: :unprocessable_entity
    end
  end

  private

  def set_relationship
    @relationship = @family.relationships.find(params[:id])
  end

  def assessment_params
    params.require(:relationship_assessment).permit(
      :score_cooperation, :score_affection, :score_trust,
      :whats_working, :whats_not_working, :action_items
    )
  end
end

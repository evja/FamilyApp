require "test_helper"

class RelationshipAssessmentTest < ActiveSupport::TestCase
  test "validates score ranges" do
    assessment = RelationshipAssessment.new(
      relationship: relationships(:parent_to_parent),
      score_cooperation: 3,
      score_affection: 1,
      score_trust: 1
    )

    refute assessment.valid?
    assert assessment.errors[:score_cooperation].any?
  end

  test "computes total_score before save" do
    assessment = RelationshipAssessment.create!(
      relationship: relationships(:parent_to_child),
      score_cooperation: 2,
      score_affection: 1,
      score_trust: 2
    )

    assert_equal 5, assessment.total_score
  end

  test "computes quarter_key before save" do
    assessment = RelationshipAssessment.create!(
      relationship: relationships(:parent_to_child),
      score_cooperation: 1,
      score_affection: 1,
      score_trust: 1,
      assessed_on: Date.new(2026, 2, 6)
    )

    assert_equal "2026-Q1", assessment.quarter_key
  end

  test "band_label returns correct label" do
    assert_equal 'High Functioning', relationship_assessments(:high_score).band_label
    assert_equal 'Functioning', relationship_assessments(:medium_score).band_label
  end

  test "updates relationship health after commit" do
    relationship = relationships(:parent_to_child)
    refute relationship.assessed?

    RelationshipAssessment.create!(
      relationship: relationship,
      score_cooperation: 2,
      score_affection: 2,
      score_trust: 2
    )

    relationship.reload
    assert relationship.assessed?
    assert_equal 'high', relationship.current_health_band
  end

  test "sets assessed_on to current date if not provided" do
    assessment = RelationshipAssessment.create!(
      relationship: relationships(:parent_to_child),
      score_cooperation: 1,
      score_affection: 1,
      score_trust: 1
    )

    assert_equal Date.current, assessment.assessed_on
  end

  test "recent scope orders by date descending" do
    assessments = RelationshipAssessment.recent
    dates = assessments.map(&:assessed_on)

    assert_equal dates, dates.sort.reverse
  end
end

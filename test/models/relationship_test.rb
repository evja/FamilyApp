require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  test "normalize_member_order swaps ids when low > high" do
    relationship = Relationship.new(
      family: families(:one),
      member_low: members(:teen_one),
      member_high: members(:admin_parent_one)
    )
    relationship.valid?

    assert relationship.member_low_id < relationship.member_high_id
  end

  test "display_name combines member names" do
    relationship = relationships(:parent_to_parent)
    assert_match /&/, relationship.display_name
  end

  test "assessed? returns true when score present" do
    assert relationships(:parent_to_parent).assessed?
  end

  test "assessed? returns false when score nil" do
    refute relationships(:parent_to_child).assessed?
  end

  test "health_color_hsl returns grey for unassessed" do
    assert_equal 'hsl(0, 0%, 70%)', relationships(:parent_to_child).health_color_hsl
  end

  test "health_color_hsl returns color based on score" do
    relationship = relationships(:parent_to_parent)
    color = relationship.health_color_hsl
    assert_match /hsl\(\d+, 70%, 45%\)/, color
  end

  test "health_label returns correct label" do
    assert_equal 'High Functioning', relationships(:parent_to_parent).health_label
    assert_equal 'Functioning', relationships(:parent_to_teen).health_label
    assert_equal 'Not Assessed', relationships(:parent_to_child).health_label
  end

  test "update_health_from_assessment applies EWMA" do
    relationship = relationships(:parent_to_parent)
    original_score = relationship.current_health_score

    assessment = relationship.assessments.create!(
      score_cooperation: 1,
      score_affection: 1,
      score_trust: 1,
      assessed_on: Date.current
    )

    relationship.reload
    new_pct = (3.0 / 6.0) * 100
    expected = (0.5 * new_pct + 0.5 * original_score).round

    assert_equal expected, relationship.current_health_score
  end

  test "ensure_all_for_family creates all pairs" do
    family = families(:two)
    family.relationships.destroy_all

    # Create some members for this family
    member1 = family.members.create!(name: "Test Parent", role: "parent", email: "test1@example.com")
    member2 = family.members.create!(name: "Test Teen", role: "teen", email: "test2@example.com")
    member3 = family.members.create!(name: "Test Child", role: "child")

    member_count = family.members.count
    expected_pairs = (member_count * (member_count - 1)) / 2

    Relationship.ensure_all_for_family(family)

    assert_equal expected_pairs, family.relationships.count
  end

  test "scopes filter correctly" do
    family = families(:one)

    assert Relationship.assessed.include?(relationships(:parent_to_parent))
    assert Relationship.unassessed.include?(relationships(:parent_to_child))
    assert Relationship.healthy.include?(relationships(:parent_to_parent))
    assert Relationship.needs_attention.include?(relationships(:parent_to_teen))
  end

  test "for_member scope finds relationships" do
    member = members(:admin_parent_one)
    relationships = Relationship.for_member(member)

    assert relationships.any?
    relationships.each do |r|
      assert r.member_low_id == member.id || r.member_high_id == member.id
    end
  end
end

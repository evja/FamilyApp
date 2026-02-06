require "test_helper"

class RhythmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @family = families(:one)
    @rhythm = rhythms(:weekly_parent_sync)
    sign_in @user
  end

  test "should get index" do
    get family_rhythms_url(@family)
    assert_response :success
  end

  test "should get new" do
    get new_family_rhythm_url(@family)
    assert_response :success
  end

  test "should get show" do
    get family_rhythm_url(@family, @rhythm)
    assert_response :success
  end

  test "should get edit" do
    get edit_family_rhythm_url(@family, @rhythm)
    assert_response :success
  end

  test "should get setup" do
    get setup_family_rhythms_url(@family)
    assert_response :success
  end

  test "should create rhythm from template" do
    # First delete any existing rhythm with this name
    @family.rhythms.where(name: "1-on-1 Check-in").destroy_all

    assert_difference("Rhythm.count") do
      post family_rhythms_url(@family), params: { template_name: "1-on-1 Check-in" }
    end
    assert_redirected_to family_rhythm_url(@family, Rhythm.last)
  end

  test "should create custom rhythm" do
    assert_difference("Rhythm.count") do
      post family_rhythms_url(@family), params: {
        rhythm: {
          name: "Custom Test Rhythm",
          frequency_type: "weekly",
          rhythm_category: "custom",
          description: "Test description"
        }
      }
    end
    # Redirects to edit page so user can add agenda items
    assert_redirected_to edit_family_rhythm_url(@family, Rhythm.last)
  end

  test "should update rhythm" do
    patch family_rhythm_url(@family, @rhythm), params: {
      rhythm: { name: "Updated Name" }
    }
    assert_redirected_to family_rhythm_url(@family, @rhythm)
    @rhythm.reload
    assert_equal "Updated Name", @rhythm.name
  end

  test "should destroy rhythm" do
    rhythm = @family.rhythms.create!(
      name: "Temporary Rhythm",
      frequency_type: "weekly",
      frequency_days: 7,
      rhythm_category: "custom"
    )

    assert_difference("Rhythm.count", -1) do
      delete family_rhythm_url(@family, rhythm)
    end
    assert_redirected_to family_rhythms_url(@family)
  end

  test "should start meeting" do
    # Ensure no current meeting exists
    @rhythm.completions.where(status: "in_progress").destroy_all

    assert_difference("RhythmCompletion.count") do
      post start_family_rhythm_url(@family, @rhythm)
    end
    assert_redirected_to run_family_rhythm_url(@family, @rhythm)
  end

  test "should get run with meeting in progress" do
    # Start a meeting first
    @rhythm.completions.where(status: "in_progress").destroy_all
    @rhythm.start_meeting!(@user)

    get run_family_rhythm_url(@family, @rhythm)
    assert_response :success
  end

  test "should check item" do
    # Set up a meeting with items
    @rhythm.completions.where(status: "in_progress").destroy_all
    completion = @rhythm.start_meeting!(@user)
    item = completion.completion_items.first

    post check_item_family_rhythm_url(@family, @rhythm), params: { item_id: item.id }

    item.reload
    assert item.checked?
  end

  test "should uncheck item" do
    # Set up a meeting with a checked item
    @rhythm.completions.where(status: "in_progress").destroy_all
    completion = @rhythm.start_meeting!(@user)
    item = completion.completion_items.first
    item.check!

    post uncheck_item_family_rhythm_url(@family, @rhythm), params: { item_id: item.id }

    item.reload
    assert_not item.checked?
  end

  test "should finish meeting" do
    # Start and complete all items
    @rhythm.completions.where(status: "in_progress").destroy_all
    completion = @rhythm.start_meeting!(@user)
    completion.completion_items.each(&:check!)

    post finish_family_rhythm_url(@family, @rhythm)

    @rhythm.reload
    assert_not_nil @rhythm.last_completed_at
    assert_not_nil @rhythm.next_due_at
    assert_redirected_to family_rhythm_url(@family, @rhythm)
  end

  test "should skip rhythm" do
    old_next_due = @rhythm.next_due_at

    post skip_family_rhythm_url(@family, @rhythm)

    @rhythm.reload
    assert @rhythm.next_due_at > old_next_due
    assert_redirected_to family_rhythms_url(@family)
  end

  test "should update setup with selected templates" do
    # Clean up any existing rhythms from templates
    @family.rhythms.where(name: "Weekly Family Huddle").destroy_all

    assert_difference("Rhythm.count") do
      post update_setup_family_rhythms_url(@family), params: {
        templates: ["Weekly Family Huddle"]
      }
    end
    assert_redirected_to family_rhythms_url(@family)
  end

  test "should not allow access to other family rhythms" do
    other_family = families(:two)
    other_rhythm = rhythms(:family_two_rhythm)

    get family_rhythm_url(other_family, other_rhythm)
    assert_redirected_to root_path
  end
end

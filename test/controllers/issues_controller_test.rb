require "test_helper"

class IssuesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @family = families(:one)
    @issue = issues(:one)
    sign_in @user
  end

  test "should get index" do
    get family_issues_url(@family)
    assert_response :success
  end

  test "should get new" do
    get new_family_issue_url(@family)
    assert_response :success
  end

  test "should show issue" do
    get family_issue_url(@family, @issue)
    assert_response :success
  end

  test "should get edit" do
    get edit_family_issue_url(@family, @issue)
    assert_response :success
  end

  test "should destroy issue" do
    issue = Issue.create!(family: @family, list_type: "Family", description: "Temporary test issue")
    assert_difference("Issue.count", -1) do
      delete family_issue_url(@family, issue)
    end
  end
end

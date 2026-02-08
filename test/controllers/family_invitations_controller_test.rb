require "test_helper"

class FamilyInvitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @family = families(:one)
    @valid_invitation = family_invitations(:valid_pending)
    @expired_invitation = family_invitations(:one)
  end

  # --- Accept: unauthenticated ---

  test "accept stores token in session and redirects to sign up when not logged in" do
    get accept_family_invitation_url(token: @valid_invitation.token)
    assert_redirected_to new_user_registration_path
    assert_equal "Please create an account to join the family.", flash[:notice]
  end

  # --- Accept: expired invitation ---

  test "accept rejects expired invitation" do
    user = users(:no_family)
    sign_in user

    # Update email to match the expired invitation
    user.update!(email: @expired_invitation.email)

    get accept_family_invitation_url(token: @expired_invitation.token)
    assert_redirected_to root_path
    assert_equal "Invalid or expired invitation.", flash[:alert]
  end

  # --- Accept: invalid token ---

  test "accept rejects invalid token" do
    sign_in users(:one)
    get accept_family_invitation_url(token: "nonexistent_token")
    assert_redirected_to root_path
    assert_equal "Invalid or expired invitation.", flash[:alert]
  end

  # --- Accept: email mismatch ---

  test "accept rejects when email does not match" do
    user = users(:no_family)
    sign_in user

    # The valid_for_user_two invitation is for user-two@example.com, not no-family@example.com
    invitation = family_invitations(:valid_for_user_two)
    get accept_family_invitation_url(token: invitation.token)
    assert_redirected_to root_path
    assert_equal "This invitation was sent to a different email address.", flash[:alert]
  end

  # --- Accept: user already in different family (multi-family support) ---

  test "accept allows user already in different family to join new family" do
    user = users(:two)  # belongs to family :two
    original_family = user.family
    sign_in user

    invitation = family_invitations(:valid_for_user_two)
    get accept_family_invitation_url(token: invitation.token)

    user.reload
    invitation.reload

    # User should now be a member of the new family and have it as current
    assert_equal invitation.family, user.current_family
    assert_equal "accepted", invitation.status
    assert_redirected_to family_path(invitation.family)
    assert_equal "Welcome to the family!", flash[:notice]
  end

  # --- Accept: happy path ---

  test "accept joins family when logged in with matching email and no family" do
    user = users(:no_family)
    sign_in user

    assert_nil user.family_id
    get accept_family_invitation_url(token: @valid_invitation.token)

    user.reload
    @valid_invitation.reload

    assert_equal @family.id, user.family_id
    assert_equal "accepted", @valid_invitation.status
    assert_redirected_to family_path(@family)
    assert_equal "Welcome to the family!", flash[:notice]
  end

  # --- Accept: user already in same family ---

  test "accept succeeds when user is already in the same family" do
    user = users(:no_family)
    user.update!(family: @family)
    sign_in user

    get accept_family_invitation_url(token: @valid_invitation.token)

    user.reload
    @valid_invitation.reload

    assert_equal @family.id, user.family_id
    assert_equal "accepted", @valid_invitation.status
    assert_redirected_to family_path(@family)
  end
end

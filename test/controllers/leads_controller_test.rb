require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  test "should create lead" do
    assert_difference("Lead.count") do
      post leads_url, params: { lead: { first_name: "John", last_name: "Doe", email: "newlead@example.com" } }
    end
    assert_redirected_to root_url
  end

  test "should handle validation errors" do
    assert_no_difference("Lead.count") do
      post leads_url, params: { lead: { email: "newlead@example.com" } }
    end
    assert_redirected_to root_url
  end

  test "should reject honeypot submissions silently" do
    assert_no_difference("Lead.count") do
      post leads_url, params: { lead: { first_name: "Bot", last_name: "Spam", email: "bot@spam.com", hp: "spam value" } }
    end
    # Should still redirect as if successful (to fool bots)
    assert_redirected_to root_url
  end

  test "should update lead with survey data" do
    lead = Lead.create!(first_name: "Jane", last_name: "Doe", email: "jane@example.com")

    patch lead_url(lead), params: { lead: { family_size: 4, biggest_challenge: "communication" } }

    lead.reload
    assert lead.survey_completed
    assert_equal 4, lead.family_size
    assert_equal "communication", lead.biggest_challenge
    assert_redirected_to root_url
  end

  test "signal strength increases with survey completion" do
    lead = Lead.create!(first_name: "Test", last_name: "User", email: "test@example.com")
    initial_signal = lead.signal_strength

    patch lead_url(lead), params: { lead: { family_size: 4, biggest_challenge: "alignment" } }

    lead.reload
    assert lead.signal_strength > initial_signal
  end
end

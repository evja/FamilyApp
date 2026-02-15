module OnboardingsHelper
  ONBOARDING_STEPS = %w[welcome add_members first_issue dashboard_intro].freeze

  def onboarding_step_number(state)
    index = ONBOARDING_STEPS.index(state)
    index ? index + 1 : 1
  end

  def onboarding_progress_percentage(state)
    return 100 if state == 'complete'

    step = onboarding_step_number(state)
    total = ONBOARDING_STEPS.length
    ((step - 1).to_f / total * 100).round
  end

  def onboarding_step_title(state)
    {
      'welcome' => 'Welcome',
      'add_members' => 'Add Your Family',
      'first_issue' => 'Capture Your First Issue',
      'dashboard_intro' => 'Nice Work!'
    }[state] || 'Welcome'
  end

  def onboarding_step_subtitle(state)
    {
      'welcome' => 'Step 1 of 4',
      'add_members' => 'Step 2 of 4',
      'first_issue' => 'Step 3 of 4',
      'dashboard_intro' => 'Step 4 of 4'
    }[state] || 'Step 1 of 4'
  end
end

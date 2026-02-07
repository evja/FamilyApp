module ApplicationHelper
  # ============================================================================
  # PROGRESSIVE MODULE UNLOCK SYSTEM
  # ============================================================================

  def module_unlocked?(module_name)
    return true if show_admin_features?

    case module_name.to_s.downcase.to_sym
    when :members
      true
    when :vision
      @family.members.count > 1
    when :issues
      vision_complete?
    when :rhythms
      module_unlocked?(:issues) && @family.issues.count >= 1
    when :relationships
      module_unlocked?(:issues)
    when :responsibilities, :rituals
      module_unlocked?(:rhythms)
    else
      false
    end
  end

  def vision_complete?
    return false unless @family&.vision.present?
    @family.vision.mission_statement.present? &&
      @family.vision.mission_statement.length >= 10
  end

  def next_unlockable_module
    return nil if show_admin_features?

    [:members, :vision, :issues, :rhythms, :relationships, :responsibilities, :rituals].each do |mod|
      return mod unless module_unlocked?(mod)
    end
    nil
  end

  def module_unlock_message(module_name)
    {
      vision: "Every family needs a shared direction.",
      issues: "Problems don't go away when ignored - they grow.",
      rhythms: "What you don't schedule, you drift from.",
      relationships: "Connection requires intention.",
      responsibilities: "Growth happens through consistent practice.",
      rituals: "Rituals create the moments that matter."
    }[module_name.to_sym]
  end

  def module_unlock_condition(module_name)
    {
      vision: "Add your family members to unlock",
      issues: "Complete your family vision to start capturing issues",
      rhythms: "Create your first issue to unlock Rhythms",
      relationships: "Complete your family vision (unlocks with Issues)",
      responsibilities: "Create your first rhythm to unlock Responsibilities",
      rituals: "Create your first rhythm to unlock Rituals"
    }[module_name.to_sym]
  end

  def module_unlock_progress(module_name)
    case module_name.to_sym
    when :vision
      { current: @family.members.count, required: 1, label: "members", type: :numeric }
    when :issues
      { complete: vision_complete?, label: "vision complete", type: :boolean }
    when :rhythms
      if module_unlocked?(:issues)
        { current: @family.issues.count, required: 1, label: "issues", type: :numeric }
      else
        { prerequisite: "Unlock Issues first", type: :blocked }
      end
    when :relationships
      { complete: module_unlocked?(:issues), label: "issues unlocked", type: :boolean }
    when :responsibilities, :rituals
      { complete: module_unlocked?(:rhythms), label: "rhythms unlocked", type: :boolean }
    else
      nil
    end
  end

  def module_visible_to_user?(module_key)
    is_unlocked = module_unlocked?(module_key)
    is_hidden_by_admin = session[:hidden_modules]&.include?(module_key.to_s.capitalize)

    (show_admin_features? || is_unlocked) && !is_hidden_by_admin
  end
end

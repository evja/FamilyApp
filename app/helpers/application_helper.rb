module ApplicationHelper
  # ============================================================================
  # PROGRESSIVE MODULE UNLOCK SYSTEM
  # ============================================================================

  # Progressive unlock based on transformation tiers:
  # Stabilize (Plug the holes)  → Members + Issues
  # Orient (Organize the ship)  → Rhythms + Relationships
  # Operate (Set sail)          → Vision + Responsibilities + Rituals
  def module_unlocked?(module_name)
    return true if show_admin_features?

    case module_name.to_s.downcase.to_sym
    when :members
      # Always unlocked - entry point
      true
    when :issues
      # Stabilize tier: 1+ members added
      @family.members.count > 1
    when :rhythms
      # Orient tier: 1+ issue logged
      module_unlocked?(:issues) && @family.issues.count >= 1
    when :relationships
      # Orient tier: 1+ member beyond admin (need pairs)
      @family.members.count > 1
    when :vision
      # Operate tier: 1+ rhythm completed (earned through action)
      @family.rhythms.joins(:completions).where(rhythm_completions: { status: 'completed' }).exists?
    when :responsibilities, :rituals
      # Operate tier: Vision started
      vision_complete?
    else
      false
    end
  end

  def vision_complete?
    return false unless @family&.vision.present?
    @family.vision.mission_statement.present? &&
      @family.vision.mission_statement.length >= 10
  end

  # Order follows transformation tiers: Stabilize → Orient → Operate
  def next_unlockable_module
    return nil if show_admin_features?

    [:members, :issues, :relationships, :rhythms, :vision, :responsibilities, :rituals].each do |mod|
      return mod unless module_unlocked?(mod)
    end
    nil
  end

  def module_unlock_message(module_name)
    {
      issues: "Problems don't go away when ignored - they grow.",
      relationships: "Connection requires intention.",
      rhythms: "What you don't schedule, you drift from.",
      vision: "Every family needs a shared direction.",
      responsibilities: "Growth happens through consistent practice.",
      rituals: "Rituals create the moments that matter."
    }[module_name.to_sym]
  end

  def module_unlock_condition(module_name)
    {
      issues: "Add your family members to start capturing issues",
      relationships: "Add your family members to track relationships",
      rhythms: "Create your first issue to unlock Rhythms",
      vision: "Complete a rhythm meeting to unlock Vision",
      responsibilities: "Complete your family vision to unlock Responsibilities",
      rituals: "Complete your family vision to unlock Rituals"
    }[module_name.to_sym]
  end

  def module_unlock_progress(module_name)
    case module_name.to_sym
    when :issues
      { current: @family.members.count - 1, required: 1, label: "members (beyond you)", type: :numeric }
    when :relationships
      { current: @family.members.count - 1, required: 1, label: "members (beyond you)", type: :numeric }
    when :rhythms
      if module_unlocked?(:issues)
        { current: @family.issues.count, required: 1, label: "issues", type: :numeric }
      else
        { prerequisite: "Unlock Issues first", type: :blocked }
      end
    when :vision
      completed_rhythm = @family.rhythms.joins(:completions).where(rhythm_completions: { status: 'completed' }).exists?
      { complete: completed_rhythm, label: "rhythm completed", type: :boolean }
    when :responsibilities, :rituals
      { complete: vision_complete?, label: "vision complete", type: :boolean }
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

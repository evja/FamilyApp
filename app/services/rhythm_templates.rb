class RhythmTemplates
  TEMPLATES = [
    {
      name: "Weekly Parent Sync",
      description: "A focused weekly meeting for parents to align on family priorities, discuss challenges, and coordinate schedules.",
      frequency_type: "weekly",
      frequency_days: 7,
      rhythm_category: "parent_sync",
      agenda_items: [
        { position: 0, title: "Check-in: How are you feeling?", duration_minutes: 5, instructions: "Share your emotional state and energy level this week.", link_type: "none" },
        { position: 1, title: "Wins from the week", duration_minutes: 5, instructions: "Celebrate what went well - big or small victories.", link_type: "none" },
        { position: 2, title: "Review open issues", duration_minutes: 10, instructions: "Check on any ongoing family challenges and their progress.", link_type: "issues" },
        { position: 3, title: "Calendar review", duration_minutes: 10, instructions: "Look at the upcoming week and coordinate schedules.", link_type: "none" },
        { position: 4, title: "Kid updates", duration_minutes: 10, instructions: "Discuss how each child is doing - school, social, emotional.", link_type: "members" },
        { position: 5, title: "Household logistics", duration_minutes: 10, instructions: "Address any practical matters - chores, repairs, purchases.", link_type: "none" },
        { position: 6, title: "Connection time planning", duration_minutes: 5, instructions: "Plan intentional time together as a couple and as a family.", link_type: "none" },
        { position: 7, title: "Closing: One thing you appreciate", duration_minutes: 5, instructions: "Share one thing you appreciate about your partner.", link_type: "none" }
      ]
    },
    {
      name: "Weekly Family Huddle",
      description: "A short weekly gathering to connect as a family, review the week, and plan ahead together.",
      frequency_type: "weekly",
      frequency_days: 7,
      rhythm_category: "family_huddle",
      agenda_items: [
        { position: 0, title: "High-five circle", duration_minutes: 5, instructions: "Each person shares their biggest win from the week.", link_type: "none" },
        { position: 1, title: "Family values check-in", duration_minutes: 10, instructions: "Review your family values and discuss how you lived them out.", link_type: "vision" },
        { position: 2, title: "Upcoming week preview", duration_minutes: 10, instructions: "Go through the calendar and make sure everyone knows what's happening.", link_type: "none" },
        { position: 3, title: "Family fun planning", duration_minutes: 10, instructions: "Decide on one fun activity to do together this week.", link_type: "none" },
        { position: 4, title: "Appreciations", duration_minutes: 10, instructions: "Each person shares something they appreciate about another family member.", link_type: "members" }
      ]
    },
    {
      name: "Quarterly Parent Retreat",
      description: "A deeper planning session for parents to review progress, reconnect, and set goals for the next quarter.",
      frequency_type: "quarterly",
      frequency_days: 90,
      rhythm_category: "retreat",
      agenda_items: [
        { position: 0, title: "Extended check-in", duration_minutes: 30, instructions: "How are you really doing? Share openly about your wellbeing.", link_type: "none" },
        { position: 1, title: "Quarter in review", duration_minutes: 30, instructions: "Look back at the past 3 months. What worked? What didn't?", link_type: "none" },
        { position: 2, title: "Family vision review", duration_minutes: 30, instructions: "Revisit your family vision and values. Are you on track?", link_type: "vision" },
        { position: 3, title: "Individual child focus", duration_minutes: 45, instructions: "Discuss each child in depth - development, needs, opportunities.", link_type: "members" },
        { position: 4, title: "Relationship health", duration_minutes: 30, instructions: "Honestly assess your relationship. What needs attention?", link_type: "none" },
        { position: 5, title: "Goals for next quarter", duration_minutes: 30, instructions: "Set 2-3 family goals and 2-3 personal/couple goals.", link_type: "none" },
        { position: 6, title: "Closing ritual", duration_minutes: 15, instructions: "End with gratitude and affirmation of your partnership.", link_type: "none" }
      ]
    },
    {
      name: "Annual Parent Retreat",
      description: "A comprehensive yearly planning session to reflect on the past year and dream together about the future.",
      frequency_type: "annually",
      frequency_days: 365,
      rhythm_category: "retreat",
      agenda_items: [
        { position: 0, title: "Year in review: Personal", duration_minutes: 45, instructions: "Each parent reflects on their personal growth and challenges.", link_type: "none" },
        { position: 1, title: "Year in review: Family", duration_minutes: 45, instructions: "Review family highlights, challenges, and growth together.", link_type: "none" },
        { position: 2, title: "Year in review: Kids", duration_minutes: 60, instructions: "Celebrate each child's growth and discuss their journey.", link_type: "members" },
        { position: 3, title: "Vision and values refresh", duration_minutes: 60, instructions: "Review and update your family vision and values.", link_type: "vision" },
        { position: 4, title: "Big picture dreams", duration_minutes: 45, instructions: "Dream together about 5-10 years from now. What do you want?", link_type: "vision" },
        { position: 5, title: "Year ahead planning", duration_minutes: 60, instructions: "Set major goals and intentions for the coming year.", link_type: "none" },
        { position: 6, title: "Budget and resources", duration_minutes: 45, instructions: "Review finances and plan for major expenses or investments.", link_type: "none" },
        { position: 7, title: "Relationship intentions", duration_minutes: 30, instructions: "Set intentions for your relationship in the coming year.", link_type: "none" },
        { position: 8, title: "Closing celebration", duration_minutes: 30, instructions: "Celebrate your partnership and express gratitude.", link_type: "none" }
      ]
    },
    {
      name: "1-on-1 Check-in",
      description: "A focused conversation with one family member to connect, listen, and support.",
      frequency_type: "weekly",
      frequency_days: 7,
      rhythm_category: "check_in",
      agenda_items: [
        { position: 0, title: "Connection opener", duration_minutes: 5, instructions: "Start with a fun question or just chat about their day.", link_type: "none" },
        { position: 1, title: "Highs and lows", duration_minutes: 10, instructions: "Ask about the best and hardest parts of their week.", link_type: "none" },
        { position: 2, title: "What's on your mind?", duration_minutes: 10, instructions: "Create space for them to share anything that's bothering them.", link_type: "none" },
        { position: 3, title: "How can I help?", duration_minutes: 5, instructions: "Ask if there's anything they need from you.", link_type: "none" },
        { position: 4, title: "Closing affirmation", duration_minutes: 5, instructions: "End with words of encouragement and love.", link_type: "none" }
      ]
    },
    {
      name: "Relationship Health Check",
      description: "Quarterly assessment of family relationship bonds using cooperation, affection, and trust scores.",
      frequency_type: "quarterly",
      frequency_days: 90,
      rhythm_category: "retreat",
      agenda_items: [
        { position: 0, title: "Gratitude Round", duration_minutes: 5, instructions: "Each person shares something they appreciate about family relationships.", link_type: "none" },
        { position: 1, title: "Assess Relationships", duration_minutes: 30, instructions: "Go through each relationship and score cooperation, affection, and trust.", link_type: "relationships" },
        { position: 2, title: "Identify Focus Areas", duration_minutes: 15, instructions: "Which relationships need the most attention? Create action items.", link_type: "issues" }
      ]
    }
  ].freeze

  class << self
    def template_list
      TEMPLATES.map do |t|
        {
          name: t[:name],
          description: t[:description],
          frequency_type: t[:frequency_type],
          rhythm_category: t[:rhythm_category],
          item_count: t[:agenda_items].size,
          total_duration: t[:agenda_items].sum { |i| i[:duration_minutes] || 0 }
        }
      end
    end

    def find_template(name)
      TEMPLATES.find { |t| t[:name] == name }
    end

    def create_from_template(family, template_name, activate: false)
      template = find_template(template_name)
      return nil unless template

      rhythm = family.rhythms.create!(
        name: template[:name],
        description: template[:description],
        frequency_type: template[:frequency_type],
        frequency_days: template[:frequency_days],
        rhythm_category: template[:rhythm_category],
        is_active: activate,
        next_due_at: activate ? Time.current + template[:frequency_days].days : nil
      )

      template[:agenda_items].each do |item_attrs|
        rhythm.agenda_items.create!(item_attrs)
      end

      rhythm
    end

    def create_defaults_for(family, activate: false)
      created = []
      TEMPLATES.each do |template|
        next if family.rhythms.exists?(name: template[:name])

        rhythm = create_from_template(family, template[:name], activate: activate)
        created << rhythm if rhythm
      end
      created
    end

    def category_groups
      {
        "parent_sync" => "Parent Meetings",
        "family_huddle" => "Family Meetings",
        "retreat" => "Retreats",
        "check_in" => "Check-ins"
      }
    end

    def templates_by_category
      TEMPLATES.group_by { |t| t[:rhythm_category] }
    end
  end
end

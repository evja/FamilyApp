class MaturityChartSeeder
  # Default maturity chart based on Family Operating System principles
  # Each level represents age-appropriate expectations and privileges

  LEVELS = [
    {
      name: "Yellow (3-6)",
      color_code: "#FCD34D",
      age_min: 3,
      age_max: 6,
      position: 0,
      description: "Foundation years focusing on basic self-care and following simple routines.",
      behaviors: {
        body: [
          "Brushes teeth with supervision",
          "Washes hands before meals",
          "Uses toilet independently (with help wiping)",
          "Takes baths with parental help"
        ],
        things: [
          "Puts toys away when asked",
          "Handles books gently",
          "Knows where belongings go"
        ],
        clothing: [
          "Puts on simple clothing with help",
          "Takes off shoes and socks",
          "Puts dirty clothes in hamper"
        ],
        responsibilities: [
          "Feeds pets with supervision",
          "Helps set the table",
          "Picks up own toys"
        ],
        emotions: [
          "Uses words to express feelings",
          "Says please and thank you",
          "Waits for turn with help"
        ]
      },
      privileges: {
        money: { description: "No allowance yet", value: nil },
        bedtime: { description: "Bedtime", value: "7:00 pm" },
        screen_time: { description: "Screen time limit", value: "30 min/day" },
        food: { description: "Snacks provided by parents", value: nil },
        social: { description: "Playdates with parent present", value: nil }
      }
    },
    {
      name: "Orange (7-8)",
      color_code: "#FB923C",
      age_min: 7,
      age_max: 8,
      position: 1,
      description: "Growing independence in self-care and developing consistent habits.",
      behaviors: {
        body: [
          "Brushes teeth independently",
          "Showers independently",
          "Combs own hair",
          "Clips own fingernails with supervision"
        ],
        things: [
          "Makes bed daily",
          "Keeps room tidy",
          "Takes care of personal items",
          "Puts dishes in sink after meals"
        ],
        clothing: [
          "Dresses independently",
          "Chooses weather-appropriate clothes",
          "Ties own shoes",
          "Puts away clean laundry"
        ],
        responsibilities: [
          "Completes simple chores without reminders",
          "Helps with meal preparation",
          "Waters plants",
          "Takes out trash in house"
        ],
        emotions: [
          "Manages frustration with words",
          "Apologizes when wrong",
          "Shows empathy to others",
          "Handles small disappointments"
        ]
      },
      privileges: {
        money: { description: "Weekly allowance", value: "$5.00" },
        bedtime: { description: "Bedtime", value: "8:00 pm" },
        screen_time: { description: "Screen time limit", value: "45 min/day" },
        food: { description: "Can choose own healthy snacks", value: nil },
        social: { description: "Playdates in the neighborhood", value: nil }
      }
    },
    {
      name: "Green (9-11)",
      color_code: "#4ADE80",
      age_min: 9,
      age_max: 11,
      position: 2,
      description: "Taking ownership of routines and developing accountability.",
      behaviors: {
        body: [
          "Manages complete hygiene routine",
          "Showers daily without reminders",
          "Uses deodorant appropriately",
          "Keeps nails trimmed"
        ],
        things: [
          "Organizes own space",
          "Maintains belongings in good condition",
          "Handles electronics responsibly",
          "Cleans up after activities"
        ],
        clothing: [
          "Does own laundry (with supervision)",
          "Plans outfits for events",
          "Takes pride in appearance",
          "Organizes closet and drawers"
        ],
        responsibilities: [
          "Manages homework independently",
          "Helps with family chores",
          "Cares for younger siblings briefly",
          "Prepares simple meals"
        ],
        emotions: [
          "Communicates needs clearly",
          "Handles peer conflicts constructively",
          "Shows gratitude regularly",
          "Accepts constructive criticism"
        ]
      },
      privileges: {
        money: { description: "Weekly allowance", value: "$8.00" },
        bedtime: { description: "Bedtime", value: "8:30 pm" },
        screen_time: { description: "Screen time limit", value: "60 min/day" },
        food: { description: "Can prepare own snacks", value: nil },
        social: { description: "Can visit friends' houses", value: nil },
        independence: { description: "Short errands in neighborhood", value: nil }
      }
    },
    {
      name: "Blue (12-13)",
      color_code: "#60A5FA",
      age_min: 12,
      age_max: 13,
      position: 3,
      description: "Pre-teen independence with increasing responsibility and trust.",
      behaviors: {
        body: [
          "Complete self-care routine",
          "Manages personal health needs",
          "Makes healthy lifestyle choices",
          "Schedules own hygiene routine"
        ],
        things: [
          "Maintains study space",
          "Repairs and maintains belongings",
          "Manages personal budget basics",
          "Tracks own schedule"
        ],
        clothing: [
          "Does laundry independently",
          "Shops for basics with guidance",
          "Maintains wardrobe",
          "Appropriate dress for occasions"
        ],
        responsibilities: [
          "Manages school responsibilities",
          "Babysits younger siblings",
          "Contributes to family meals",
          "Handles increased chores"
        ],
        emotions: [
          "Navigates social situations",
          "Sets personal boundaries",
          "Manages stress appropriately",
          "Seeks help when needed"
        ]
      },
      privileges: {
        money: { description: "Weekly allowance", value: "$12.00" },
        bedtime: { description: "Bedtime on school nights", value: "9:00 pm" },
        screen_time: { description: "Screen time limit", value: "90 min/day" },
        food: { description: "Can cook simple meals", value: nil },
        social: { description: "Can go to movies/mall with friends", value: nil },
        independence: { description: "Bike in expanded neighborhood", value: nil }
      }
    },
    {
      name: "Red (14-15)",
      color_code: "#F87171",
      age_min: 14,
      age_max: 15,
      position: 4,
      description: "High school years with significant independence and accountability.",
      behaviors: {
        body: [
          "Fully independent self-care",
          "Schedules own appointments",
          "Makes fitness/health choices",
          "Maintains sleep schedule"
        ],
        things: [
          "Manages personal finances",
          "Maintains technology responsibly",
          "Organizes long-term projects",
          "Keeps commitments"
        ],
        clothing: [
          "Full wardrobe management",
          "Budgets for clothing",
          "Maintains dress code awareness",
          "Professional appearance when needed"
        ],
        responsibilities: [
          "Part-time job or volunteer work",
          "Significant household contributions",
          "Manages extracurriculars",
          "Plans ahead for deadlines"
        ],
        emotions: [
          "Handles complex social dynamics",
          "Demonstrates leadership",
          "Manages academic stress",
          "Maintains healthy relationships"
        ]
      },
      privileges: {
        money: { description: "Weekly allowance (may have job)", value: "$20.00" },
        bedtime: { description: "Bedtime on school nights", value: "10:00 pm" },
        screen_time: { description: "Screen time limit", value: "2 hrs/day" },
        food: { description: "Independent food choices", value: nil },
        social: { description: "Dating with guidelines", value: nil },
        independence: { description: "Public transportation allowed", value: nil }
      }
    },
    {
      name: "Brown (16-17)",
      color_code: "#A78BFA",
      age_min: 16,
      age_max: 17,
      position: 5,
      description: "Pre-adult preparation with near-full independence and responsibility.",
      behaviors: {
        body: [
          "Models healthy lifestyle",
          "Manages medical appointments",
          "Makes wellness decisions",
          "Maintains physical health"
        ],
        things: [
          "Manages bank account",
          "Maintains vehicle (if applicable)",
          "Handles major purchases wisely",
          "Plans for future expenses"
        ],
        clothing: [
          "Professional wardrobe building",
          "Interview-appropriate attire",
          "Budget management for clothes",
          "Style reflects maturity"
        ],
        responsibilities: [
          "Job or meaningful engagement",
          "College/career preparation",
          "Full household participation",
          "Mentors younger siblings"
        ],
        emotions: [
          "Adult-level communication",
          "Handles failure constructively",
          "Demonstrates integrity",
          "Plans for independence"
        ]
      },
      privileges: {
        money: { description: "Full financial responsibility learning", value: "Earnings + allowance" },
        bedtime: { description: "Curfew on school nights", value: "11:00 pm" },
        screen_time: { description: "Self-managed with accountability", value: nil },
        food: { description: "Meal planning participation", value: nil },
        social: { description: "Expanded dating freedom", value: nil },
        independence: { description: "Driving privileges", value: nil }
      }
    }
  ].freeze

  def self.seed_for_family(family)
    new(family).seed
  end

  def initialize(family)
    @family = family
  end

  def seed
    return if @family.maturity_levels.any?

    LEVELS.each do |level_data|
      level = @family.maturity_levels.create!(
        name: level_data[:name],
        color_code: level_data[:color_code],
        age_min: level_data[:age_min],
        age_max: level_data[:age_max],
        position: level_data[:position],
        description: level_data[:description]
      )

      # Create behaviors
      level_data[:behaviors].each_with_index do |(category, descriptions), cat_idx|
        descriptions.each_with_index do |desc, idx|
          level.behaviors.create!(
            category: category.to_s,
            description: desc,
            position: (cat_idx * 10) + idx
          )
        end
      end

      # Create privileges
      level_data[:privileges].each_with_index do |(category, priv_data), idx|
        level.privileges.create!(
          category: category.to_s,
          description: priv_data[:description],
          value: priv_data[:value],
          position: idx
        )
      end
    end

    @family.maturity_levels.ordered
  end
end

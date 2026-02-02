class VisionAssistant
  API_URL = "https://api.anthropic.com/v1/messages".freeze
  MODEL = "claude-3-haiku-20240307".freeze

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a warm, thoughtful family vision coach. A family has identified their core values and needs help crafting a mission statement.

    Rules:
    - Generate exactly 3 different mission statement suggestions
    - Each should be 1-2 sentences, warm and aspirational
    - Incorporate the family's stated values naturally
    - Make each suggestion distinct in tone: one heartfelt, one action-oriented, one poetic
    - Keep language simple and authentic — avoid corporate jargon

    Respond ONLY with valid JSON in this exact format:
    {"suggestions": ["first suggestion", "second suggestion", "third suggestion"]}
  PROMPT

  def initialize(values)
    @values = values
  end

  def call
    api_key = Rails.application.credentials.dig(:anthropic, :api_key)
    return { error: "AI assistant is not configured. Please add your Anthropic API key." } if api_key.blank?

    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 15

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = api_key
    request["anthropic-version"] = "2023-06-01"
    request.body = {
      model: MODEL,
      max_tokens: 500,
      system: SYSTEM_PROMPT,
      messages: [
        { role: "user", content: "Our family values are: #{@values.join(', ')}. Please suggest 3 mission statements." }
      ]
    }.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.error("Anthropic API error: #{response.code} #{response.body}")
      return { error: "AI assistant is temporarily unavailable. Please try again." }
    end

    body = JSON.parse(response.body)
    text = body.dig("content", 0, "text")
    result = JSON.parse(text)

    { suggestions: result["suggestions"] }
  rescue Net::OpenTimeout, Net::ReadTimeout
    { error: "AI assistant timed out. Please try again." }
  rescue JSON::ParserError
    { error: "AI assistant returned an unexpected response. Please try again." }
  rescue StandardError => e
    Rails.logger.error("VisionAssistant error: #{e.message}")
    { error: "AI assistant is temporarily unavailable. Please try again." }
  end
end

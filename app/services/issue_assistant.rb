class IssueAssistant
  API_URL = "https://api.anthropic.com/v1/messages".freeze
  MODEL = "claude-3-haiku-20240307".freeze

  SYSTEM_PROMPT = <<~PROMPT.freeze
    You are a family communication coach. A family member is describing an issue they're experiencing.
    Your job is to help them reframe it constructively — not as a complaint, but as an opportunity for growth.

    Rules:
    - Keep the same meaning but use kinder, more constructive language
    - Focus on observable behaviors and feelings, not blame
    - Keep it concise (1-3 sentences)
    - Also provide a brief tip (1 sentence) for approaching this conversation

    Respond ONLY with valid JSON in this exact format:
    {"suggested": "your reframed text here", "tip": "your tip here"}
  PROMPT

  def initialize(description)
    @description = description
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
      max_tokens: 300,
      system: SYSTEM_PROMPT,
      messages: [
        { role: "user", content: "Please help me reframe this family issue: #{@description}" }
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

    { suggested: result["suggested"], tip: result["tip"] }
  rescue Net::OpenTimeout, Net::ReadTimeout
    { error: "AI assistant timed out. Please try again." }
  rescue JSON::ParserError
    { error: "AI assistant returned an unexpected response. Please try again." }
  rescue StandardError => e
    Rails.logger.error("IssueAssistant error: #{e.message}")
    { error: "AI assistant is temporarily unavailable. Please try again." }
  end
end

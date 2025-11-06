require "net/http"
require "json"
require "uri"
require "openssl"
require "dotenv/load"

class Gemini
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models"
  CA_FILE = ENV["CA_FILE"]

  def initialize(api_key = ENV["GEMINI_API_KEY"])
    @api_key = api_key
  end

  def generate_content(model:, contents:)
    uri = URI("#{API_URL}/#{model}:generateContent?key=#{@api_key}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ca_file = CA_FILE if CA_FILE && !CA_FILE.empty?

    headers = { "Content-Type" => "application/json" }
    body = { contents: [{ parts: [{ text: contents }] }] }.to_json

    response = http.post(uri.request_uri, body, headers)
    puts "Response code: #{response.code}"

    data = JSON.parse(response.body)
    result = data.dig("candidates", 0, "content", "parts", 0, "text")
    result || data
  end
end

client = Gemini.new
puts client.generate_content(
  model: "gemini-2.5-flash",
  contents: "Explain how AI works in a few words"
)

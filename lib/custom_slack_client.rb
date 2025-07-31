require 'faraday'
require 'faraday/net_http_persistent'

class CustomSlackClient
  CONNECTION = Faraday.new(
    url: 'https://slack.com',
    headers: { 'Content-Type' => 'application/json' }
  ) do |faraday|
    faraday.adapter :net_http_persistent
  end

  def self.post_message(channel:, text:, token:)
    response = CONNECTION.post('/api/chat.postMessage') do |req|
      req.headers['Authorization'] = "Bearer #{token}"
      req.headers['Accept'] = "application/json; charset=utf-8"
      req.headers['Content-Type'] = "application/json"
      req.body = {
        channel: channel,
        text: text
      }.to_json
    end

    body = JSON.parse(response.body)
    unless body['ok']
      Rails.logger.error "Error posting to Slack: #{body['error']}"
    end
    
    response
  end
end

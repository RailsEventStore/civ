require "net/http"

module LogsParser
  class HttpAdapter
    NetworkError = Class.new(StandardError)
    ServerError  = Class.new(StandardError)

    def initialize(host:)
      @http = Net::HTTP.new(host)
    end

    def send_data(payload)
      request = Net::HTTP::Post.new("/pitboss_entries")
      request.set_form_data({
        "pitboss_entry[game_name]"  => payload.game_name,
        "pitboss_entry[value]"      => payload.data,
        "pitboss_entry[entry_type]" => payload.entry_type,
        "pitboss_entry[timestamp]"  => payload.timestamp})
      response = http.request(request)
      unless response.code_type == Net::HTTPNoContent
        raise ServerError, response.code
      end
    rescue Timeout::Error, EOFError, Errno::EINVAL,
      Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::ECONNREFUSED,
      Errno::EHOSTUNREACH, SocketError, Net::ProtocolError => e
        raise NetworkError, e.message
    end

    private

    attr_reader :http
  end
end

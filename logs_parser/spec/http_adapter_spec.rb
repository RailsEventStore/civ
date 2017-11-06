require_relative 'spec_helper'

RSpec.describe LogsParser::HttpAdapter do
  Payload = Struct.new(:game_name, :entry_type, :data, :timestamp)

  specify "send_data happy path" do
    stub_request(:post, "http://fierce-something.com/pitboss_entries")
      .with(body: {"pitboss_entry"=>{"game_name"=>"arkency123", "value"=>"7", "entry_type"=>"NewTurnStarted", "timestamp"=>"1234.56"}})
      .to_return(status: 204, body: "")

    adapter = LogsParser::HttpAdapter.new(host: "fierce-something.com")
    payload = Payload.new("arkency123", "NewTurnStarted", "7", "1234.56")
    adapter.send_data(payload)
  end

  specify "send_data server error" do
    stub_request(:post, "http://fierce-something.com/pitboss_entries")
      .with(body: {"pitboss_entry"=>{"game_name"=>"arkency123", "value"=>"7", "entry_type"=>"NewTurnStarted", "timestamp"=>"1234.56"}})
      .to_return(status: 500, body: "")

    adapter = LogsParser::HttpAdapter.new(host: "fierce-something.com")
    payload = Payload.new("arkency123", "NewTurnStarted", "7", "1234.56")
    expect { adapter.send_data(payload) }.to raise_error(LogsParser::HttpAdapter::ServerError, "500")
  end

  specify "send_data networkt error" do
    stub_request(:post, "http://fierce-something.com/pitboss_entries")
      .with(body: {"pitboss_entry"=>{"game_name"=>"arkency123", "value"=>"7", "entry_type"=>"NewTurnStarted", "timestamp"=>"1234.56"}})
      .to_timeout

    adapter = LogsParser::HttpAdapter.new(host: "fierce-something.com")
    payload = Payload.new("arkency123", "NewTurnStarted", "7", "1234.56")
    expect { adapter.send_data(payload) }.to raise_error(LogsParser::HttpAdapter::NetworkError, "execution expired")
  end
end

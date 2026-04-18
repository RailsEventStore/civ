require_relative "spec_helper"

RSpec.describe LogsParser::Service do
  specify "returns nil if line doesn't contain relevant data" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("fasd\n")
    expect(result).to be_nil
  end

  specify "turn started" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[175579.906] DBG: Game Turn 65\n")
    expect_result(result, game_name: "arkency_test", entry_type: "NewTurnStarted", data: "65", timestamp: "175579.906")
  end

  specify "player ended turn happy path" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[175687.906] Net RECV (1) :NetTurnComplete : Turn Complete, 1, 1/7\n")
    expect_result(result, game_name: "arkency_test", entry_type: "PlayerEndedTurn", data: "1", timestamp: "175687.906")
  end

  specify "player ended turn junk data" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[46739.265] Net SEND (6): size=32: NetTurnComplete : Turn Complete, 6, 0/7\n")
    expect(result).to be_nil
  end

  specify "player ended turn observer" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[175687.906] Net RECV (1) :NetTurnComplete : Turn Complete, 6, 1/7\n")
    expect(result).to be_nil
  end

  specify "player ended turn cancelled" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[47345.531] Net RECV (1) :NetTurnUnready : Turn Complete, 1 TurnCompleteStatus: 4/7\n")
    expect_result(
      result,
      game_name: "arkency_test",
      entry_type: "PlayerEndTurnCancelled",
      data: "1",
      timestamp: "47345.531"
    )
  end

  specify "player player connected happy path" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[52908.046] Net RECV (0) :NetPlayerReady(Player=0, count=2 / 2)\n")
    expect_result(result, game_name: "arkency_test", entry_type: "PlayerConnected", data: "0", timestamp: "52908.046")
  end

  specify "player player connected observer" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[52908.046] Net RECV (0) :NetPlayerReady(Player=6, count=2 / 2)\n")
    expect(result).to be_nil
  end

  specify "player player connected observer other line format" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[52907.953] Net SEND (0, 6): size=32: NetPlayerReady(Player=6, count=1 / 2)\n")
    expect(result).to be_nil
  end

  specify "player disconnected happy path" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[52906.265] DBG: ConnectionClosed Player(3)\n")
    expect_result(
      result,
      game_name: "arkency_test",
      entry_type: "PlayerDisconnected",
      data: "3",
      timestamp: "52906.265"
    )
  end

  specify "player player disconnected junk" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[52906.265] DBG: ConnectionClosed Player(-1)\n")
    expect(result).to be_nil
  end

  specify "player player connected happy path" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[3540015.559] Net RECV (1) :NetGiftUnit(Player=1, Minor=-1, UnitID=-1)\n")
    expect_result(result, game_name: "arkency_test", entry_type: "TimerReset", data: "1", timestamp: "3540015.559")
  end

  specify "city founded" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[672732.150] Net RECV (0) :NetPushMission : Do Mission, who is 0, unit ID is 8192 (Settler), mission is Found City, data1=-1, data2=-1, shift=false\n")
    expect_result(result, game_name: "arkency_test", entry_type: "CityFounded", data: "0", timestamp: "672732.150")
  end

  specify "city founded ignores settler move" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[672732.150] Net RECV (0) :NetPushMission : Do Mission, who is 0, unit ID is 8192 (Settler), mission is Move, data1=41, data2=32, shift=false\n")
    expect(result).to be_nil
  end

  specify "war status changed" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[674000.151] Net RECV (0) :NetChangeWar : Change War, rival team is 33\n")
    expect_result(result, game_name: "arkency_test", entry_type: "WarStatusChanged", data: "0", timestamp: "674000.151")
  end

  specify "city puppeted" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[674043.151] Net RECV (0) :NetDoTask : City ID 16385 (TXT_KEY_CITYSTATE_KUWAIT), doing task 19 (TASK_CREATE_PUPPET), data1 -1, data2 -1\n")
    expect_result(result, game_name: "arkency_test", entry_type: "CityPuppeted", data: "0", timestamp: "674043.151")
  end

  specify "city annexed" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[674043.151] Net RECV (0) :NetDoTask : City ID 16385 (TXT_KEY_CITY_NAME_WARSAW), doing task 20 (TASK_ANNEX), data1 -1, data2 -1\n")
    expect_result(result, game_name: "arkency_test", entry_type: "CityAnnexed", data: "0", timestamp: "674043.151")
  end

  specify "city razing started" do
    parser = LogsParser::Service.new("arkency_test", 6)
    result = parser.call("[674043.151] Net RECV (0) :NetDoTask : City ID 16385 (TXT_KEY_CITY_NAME_BERLIN), doing task 21 (TASK_RAZE), data1 -1, data2 -1\n")
    expect_result(result, game_name: "arkency_test", entry_type: "CityRazingStarted", data: "0", timestamp: "674043.151")
  end

  private

  def expect_result(result, game_name:, entry_type:, data:, timestamp:)
    expect(result.game_name).to eq(game_name)
    expect(result.entry_type).to eq(entry_type)
    expect(result.data).to eq(data)
    expect(result.timestamp).to eq(timestamp)
  end
end

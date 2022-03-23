require "domain_event"

module Game
  PlayerConnected = Class.new(DomainEvent)
  PlayerDisconnected = Class.new(DomainEvent)
  PlayerEndedTurn = Class.new(DomainEvent)
  PlayerEndTurnCancelled = Class.new(DomainEvent)
  NewTurnStarted = Class.new(DomainEvent)
  GameHosted = Class.new(DomainEvent)
  PlayerRegistered = Class.new(DomainEvent)
  PlayerUnregistered = Class.new(DomainEvent)

  HostGame = Struct.new(:game_id, :turn_timer)
  RegisterPlayer = Struct.new(:game_id, :player_id, :slot_id)
  UnregisterPlayer = Struct.new(:game_id, :player_id, :slot_id)
end

require "game/game"
require "game/service"
require "game/current_turn"

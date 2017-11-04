require 'domain_event'

module Game
  PlayerConnected        = Class.new(DomainEvent)
  PlayerDisconnected     = Class.new(DomainEvent)
  PlayerEndedTurn        = Class.new(DomainEvent)
  PlayerEndTurnCancelled = Class.new(DomainEvent)
  NewTurnStarted         = Class.new(DomainEvent)
end

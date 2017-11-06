ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.push File.expand_path('../../../spec', __FILE__)
$LOAD_PATH.push File.expand_path('../../lib',  __FILE__)

require 'game'
require 'rails_event_store/rspec'

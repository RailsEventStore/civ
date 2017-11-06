ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.push File.expand_path('../../../spec', __FILE__)

require 'webmock/rspec'
require_relative '../lib/logs_parser'
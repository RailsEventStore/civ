ENV['RAILS_ENV'] = 'test'

$LOAD_PATH.push File.expand_path('../../../spec', __FILE__)

require_relative '../lib/logs_parser'
require_relative '../lib/service'

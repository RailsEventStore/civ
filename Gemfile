source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.4.1"

gem 'rails', '~> 5.1.4'
gem 'puma', '~> 4.3'
gem 'pg', '~> 0.18'
gem 'webpacker', '~> 3.0'
gem 'will_paginate', '~> 3.1.0'

gem 'slack-ruby-client'

gem 'rails_event_store',       github: 'RailsEventStore/rails_event_store'
gem 'rails_event_store-rspec', github: 'RailsEventStore/rails_event_store'
gem 'bounded_context',         github: 'RailsEventStore/rails_event_store'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.7'
  gem 'webmock', '~>3.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

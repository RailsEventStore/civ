source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.4.1"

gem 'rails', '~> 5.1.4'
gem 'puma', '~> 3.7'
gem 'pg', '~> 0.18'
gem 'webpacker', '~> 3.0'
gem 'will_paginate', '~> 3.1.0'

gem 'rails_event_store',       github: 'RailsEventStore/rails_event_store'
gem 'rails_event_store-rspec', github: 'RailsEventStore/rails_event_store'


group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.7'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "3.0.3"

gem "rails", "~> 7.0.0"
gem "bootsnap"
gem "puma"
gem "pg"
gem "will_paginate", "~> 3.1"
gem "honeybadger"
gem "sprockets-rails"

gem "slack-ruby-client", "~> 1.0"

gem "rails_event_store", "~> 1.3.1"
gem "rails_event_store-rspec", "~> 1.3.1"
gem "bounded_context", "~> 1.3.1"

group :development, :test do
  gem "byebug", platform: :mri
  gem "rspec-rails"
  gem "webmock"
end

group :development do
  gem "listen"
end

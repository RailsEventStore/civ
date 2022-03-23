source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.7.5"

gem "rails", "~> 5.2.7"
gem "bootsnap"
gem "puma"
gem "pg"
gem "will_paginate", "~> 3.1"

gem "slack-ruby-client"

gem "rails_event_store", "~> 0.20.0"
gem "rails_event_store-rspec", "~> 0.20.0"
gem "bounded_context", "~> 0.20.0"

group :development, :test do
  gem "byebug", platform: :mri
  gem "rspec-rails", "~> 3.7"
  gem "webmock", "~> 3.1"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
end

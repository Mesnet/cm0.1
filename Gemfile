source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Basics
gem 'rails', '~> 5.1.2'
gem 'sqlite3'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'erubis'
gem 'sidekiq'
gem 'devise'
gem 'rails_admin'
gem 'cocoon'
gem 'dalli'
gem 'will_paginate-bootstrap'
gem 'rinku'

# Style
gem 'bootstrap-sass'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'font-awesome-rails'
gem 'simple_form'
gem 'client_side_validations'
gem 'client_side_validations-simple_form'
gem 'devise-bootstrapped'
# rails g devise:views:bootstrapped
gem 'data-confirm-modal'
gem 'chosen-rails'
gem 'jquery-timepicker-rails'
gem 'bootstrap-multiselect-rails'
gem 'geocoder'

# Performance test 
gem 'rack-mini-profiler'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

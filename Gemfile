source 'https://rubygems.org'

gem 'rails', '~> 5.1.3'

gem 'sqlite3'

gem 'faraday', '~> 0.12.0'

gem 'puma'

gem 'dotenv-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.5'
end

group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false

  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

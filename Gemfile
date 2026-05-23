source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.9"

gem "rails", "~> 7.1.0"
gem "sqlite3", "~> 1.4"
gem "puma", "~> 6.0"

# JWT Authentication
gem "jwt", "~> 2.7"
gem "bcrypt", "~> 3.1"

# Serialization
gem "blueprinter", "~> 0.30"

# Pagination
gem "kaminari", "~> 1.2"

# Authorization
gem "pundit", "~> 2.3"

gem "bootsnap", require: false
gem "rack-cors"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
end

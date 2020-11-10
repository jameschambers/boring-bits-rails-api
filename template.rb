def source_paths
  Array(super) + [File.expand_path(File.dirname(__FILE__))]
end

def copy_and_replace(source, dest = nil)
  dest_file = dest.nil? ? source : dest
  copy_file("templates/#{source}", dest_file, force: true)
end

remove_file 'Gemfile'
run 'touch Gemfile'
add_source 'https://rubygems.org'

# ruby '2.6.0'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'devise'
gem 'devise-jwt', '~> 0.7.0'
gem 'foreman'
gem 'jsonapi-rails'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'rack-cors'
gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem_group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  gem 'factory_bot_rails'
end

gem_group :development do
  gem 'listen', '~> 3.2'
  gem 'rubocop'
  gem 'solargraph'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

gem_group :test do
  gem 'capybara', '>= 2.15'
  gem 'faker'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'vcr'
  gem 'webdrivers'
  gem 'jsonapi-rspec'
  gem 'webmock'
end

inside 'config' do
  remove_file 'database.yml'
  create_file 'database.yml' do <<-EOF
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: #{app_name}_development

test:
  <<: *default
  database: #{app_name}_test

production:
  <<: *default
  database: #{app_name}_production

EOF
  end
end

## --------------------------------------------------
## Installers
## --------------------------------------------------

generate('devise:install')
generate('devise User')
generate('rspec:install')

## --------------------------------------------------
## DB migrations
## --------------------------------------------------

generate('devise:install')
generate('migration', 'CreateJwtDenylist jti:string:index expired_at:datetime')

## --------------------------------------------------
## Create databases
## --------------------------------------------------

rails_command('db:create')
rails_command('db:migrate')

## --------------------------------------------------
## Create files from templates
## --------------------------------------------------

copy_and_replace '.gitignore'

## Controllers
copy_and_replace 'app/controllers/application_controller.rb'
copy_and_replace 'app/controllers/registrations_controller.rb'
copy_and_replace 'app/controllers/sessions_controller.rb'
copy_and_replace 'app/controllers/api/base_controller.rb'
copy_and_replace 'app/controllers/api/users_controller.rb'

# Models
copy_and_replace 'app/models/user.rb'
copy_and_replace 'app/models/jwt_denylist.rb'

# Serializer
copy_and_replace 'app/serializable/SerializableUser.rb'

# Config
copy_and_replace 'config/initializers/devise.rb'
copy_and_replace 'config/routes.rb'
copy_and_replace 'config/initializers/rack_cors.rb'

# Spec
copy_and_replace 'spec/rails_helper.rb'
copy_and_replace 'spec/controllers/registrations_controller_spec.rb'
copy_and_replace 'spec/controllers/sessions_controller_spec.rb'
copy_and_replace 'spec/controllers/users_controller_spec.rb'

copy_and_replace 'spec/factories/users.rb'
copy_and_replace 'spec/support/api_helpers.rb'
copy_and_replace 'spec/support/user_helpers.rb'

## --------------------------------------------------
## Remove unwanted files
## --------------------------------------------------

remove_dir('test')
remove_dir('spec/models')

## --------------------------------------------------
## Set up environment variables
## --------------------------------------------------

create_file '.env' do
  "DEVISE_JWT_SECRET_KEY=#{SecureRandom.hex(64)}"
end

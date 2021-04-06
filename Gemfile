source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'activeadmin', '~> 1.0'
gem 'cancancan', '~> 1.16'
gem 'devise', '~> 4.3'
gem 'execjs', '~> 2.7'
gem 'figaro', '~> 1.1', '>= 1.1.1'
gem 'grape', '~> 1.0'
gem 'grape-entity', '~> 0.6.1'
gem 'grape-swagger', '~> 0.27.3'
gem 'grape-swagger-entity', '~> 0.2.1'
gem 'jbuilder', '~> 2.5'
gem 'mysql2', '~> 0.4.10'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.1'
gem 'rest-client', '~> 2.0', '>= 2.0.2'
gem 'sass-rails', '~> 5.0'
gem 'sentry-raven', '~> 2.5'
gem 'slack-notifier', '~> 2.3'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

gem "awesome_print"

group :development, :test do
  gem 'factory_girl_rails', '~> 4.8'
  gem 'faker', '~> 1.7', '>= 1.7.3'
  gem 'pry', '~> 0.10.4'
  gem "rspec-rails", "~> 3.0"
  gem 'rspec-grape'
  gem 'parallel'
  gem 'parallel_tests'
end

group :test do
  gem 'database_cleaner', '~> 1.6', '>= 1.6.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

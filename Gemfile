source 'https://rubygems.org'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'
gem 'activesupport', '4.1.8'
gem 'activemodel', '4.1.8'
gem 'httparty'

# Component requirements
gem 'mongoid', '5.1.1'
gem 'bson', '4.0.4'
gem 'origin', '2.2.0'
gem 'haml', '4.0.6'

# Test requirements
gem 'rspec', :group => 'test'
gem 'rack-test', :require => 'rack/test', :group => 'test'

# Padrino Stable Gem
gem 'padrino', '0.12.4'
gem 'bunny', '1.6.3'
gem 'nokogiri', '1.6.5'
gem 'forkr', '0.1.7'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core support gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.12.4'
# end
group :production do
  gem 'unicorn', '4.8.3'
#  gem 'bluepill', '0.0.68'
  gem 'eye', '0.6.4'
end

group :development do
  gem 'capistrano', '3.2.1'
  gem 'capistrano-scm-gitcopy', '0.0.7'
  gem 'capistrano-bundler'
end

gem 'nokogiri-happymapper', '0.5.9', :require => 'happymapper'
require_relative '../strategy/bart.rb'

Bart.configure do |config|
  config.refresh_time = 30
end

BartStrategy.configure do |config|
end

require_relative '../strategy/dispatcher'
require_relative '../strategy/timetable'

Providence::Strategy.configure do |config|
  config.strategies = [BartStrategy, TimetableStrategy]
  config.date_format = '%Y%m%d %H:%M:%S'
end

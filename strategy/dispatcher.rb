
module Providence
  class Dispatcher < Strategy
    class << self
      include Configurable
    end
    include Configurable
    inherit_configuration_from Strategy

    def self.strategies
      configuration.strategies || []
    end

    def initialize agency, transport
      @strategies = configuration.strategies.map { |klass| klass.new agency, transport }
    end

    def activate
      EM::MultiRequest.new.tap do |multi|
        @strategies.each { |st| multi.add st, st.activate }
      end
    end

    def do_visits_between station, start_s, end_s, limit, **_
      start_time = Time.parse(start_s)
      end_time   = Time.parse(end_s)
      EM::DefaultDeferrable.new.tap do |defer|
        @strategies.lazy.map do |strategy| 
          strategy.visits_between(station, start_time, end_time, 
                                  limit) { |r| defer.succeed r }
        end.select(&:itself).first
      end
    end
  end
end


module Providence
  class Strategy
    class << self
      include Configurable
    end
    include Configurable
    inherit_configuration_from Strategy

    def initialize agency, transport
      @transport = transport
      @agency = agency
    end

    def activate
      EM::DefaultDeferrable.new.tap { |d| d.succeed }
    end

    def visits_between station, start_time, end_time, limit=nil
      nil
    end

    protected

    def date_format
      configuration.date_format
    end
  end
end

require_relative 'strategy/dispatcher'

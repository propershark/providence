require 'eventmachine'

class Agency
  attr_reader :routes

  AGENCY_REFRESH = 300

  def initialize transport
    @transport = transport
  end

  def activate 
    EM.add_periodic_timer(AGENCY_REFRESH) do
      fetch_routes
    end

    fetch_routes
  end

  def fetch_routes
    EM::DefaultDeferrable.new.tap do |defer|
      @transport.call 'agency.routes' do |routes|
        defer.succeed routes
        @routes = routes.args.first.values
      end
    end
  end
end

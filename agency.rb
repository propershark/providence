require 'eventmachine'

class Agency
  attr_reader :routes

  AGENCY_REFRESH = 300

  def initialize transport
    @transport = transport
  end

  def activate 
    EM.add_periodic_timer(AGENCY_REFRESH) do
      fetch_routes.errback(&$stderr.method(:puts))
    end

    fetch_routes
  end

  def fetch_routes
    @transport.call('agency.routes').callback do |routes|
      @routes = routes.args.first.values
    end
  end
end

require 'eventmachine'

require_relative 'configurable'
require_relative 'configuration'
require_relative 'transport'
require_relative 'strategy'
require_relative 'agency'

require_relative 'eventmachine_ext/defer_block'
require_relative 'eventmachine_ext/multi'

module Providence
  class Runner
    def initialize opts
      @config = opts[:config]
      Dir['config/*.rb'].each { |f| require_relative f }
    end

    def start
      EM.run do
        transport = Transport.new 
        agency = Agency.new transport
        dispatcher = Dispatcher.new agency, transport

        startup = EM::MultiRequest.new
        startup.add :transport, transport.open
        startup.add :agency, agency.activate 
        startup.add :dispatcher, dispatcher.activate 

        startup.callback do
          transport.register 'providence.visits_between', &dispatcher.method(:do_visits_between)
          puts "Listening on #{transport.uri}"
        end

        Signal.trap('INT') { transport.close; exit }
      end
    end
  end
end

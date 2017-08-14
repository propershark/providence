require 'wamp_client'
require 'eventmachine'

class Transport
  class << self
    include Configurable
  end
  include Configurable
  inherit_configuration_from Transport

  include EM::Deferrable
  alias_method :once_joined, :callback

  def initialize
    begin
      @wamp_client = WampClient::Connection.new configuration.wamp
      @wamp_client.on_join { |session, _| succeed session }
    rescue Exception => e
      abort e
      require 'pry'; binding.pry
    end
  end

  # Opens the connection. WampClient::Connection#open calls EM.run, which
  # blocks the thread unless it is already in the context of an EM reactor.
  def open async: false
    if async
      Thread.new { @wamp_client.open }
    else
      @wamp_client.open
    end
    self
  end

  def ready?
    @deferred_status == :succeeded
  end

  def uri
    configuration.wamp[:uri]
  end

  def close
    @wamp_client.close
  end

  def subscribe topic
    handler = lambda do |args, kwargs, details|
      yield *args, **kwargs
    end
    once_joined do |session|
      session.subscribe topic, handler do |subscription, error, details|
        abort error if error
      end
    end
  end

  def unsubscribe subscription
    once_joined do |session|
      session.unsubscribe subscription do |subscription, error, details|
        abort error if error
      end
    end
  end

  def call rpc, args: nil, kwargs: nil
    once_joined do |session|
      session.call rpc, args, kwargs do |result, error, details|
        abort error if error
        yield result
      end
    end
  end

  # When `rpc` is invoked, the block given will be called and its result will
  # be sent to the caller. If the block returns a `Deferrable`, the transport
  # will register itself as a callback to receive an async result.
  def register rpc
    handler = lambda do |args, kwargs, details|
      begin
        result = yield *args, **kwargs
      rescue => e
        $stderr.puts e.message
        $stderr.puts e.backtrace
        raise e
      end
      if result.is_a? EM::Deferrable
        WampClient::Defer::CallDefer.new.tap { |d| result.callback { |r| d.succeed r } }
      else
        result
      end
    end
    once_joined do |session|
      session.register rpc, handler do |registration, error, details|
        abort error if error
      end
    end
  end
end

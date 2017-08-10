
module Configurable
  def self.included base
    base.extend ClassMethods
  end

  def configuration
    @configuration ||= configuration_type.new
  end
  attr_writer :configuration

  def configuration_type
    Providence::Configuration
  end

  def configure
    yield configuration
  end

  module ClassMethods
    def inherit_configuration_from type
      define_method(:configuration) do
        @configuration ||= type.configuration.dup
      end
    end
  end
end

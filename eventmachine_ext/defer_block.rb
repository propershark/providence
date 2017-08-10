
module EventMachine
  class DeferBlock
    include EventMachine::Deferrable
  
    def initialize &block
      EventMachine.defer(block, method(:succeed), method(:fail))
    end
  end

  def self.defer_block &block
    DeferBlock.new &block
  end
end

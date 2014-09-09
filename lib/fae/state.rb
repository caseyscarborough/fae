module Fae

  # A state in the state diagram.
  class State
    attr_accessor :name, :paths, :accepting

    # Creates a new state instance.
    #
    # @param name [String] the state name, i.e.: "A"
    # @param next_states [Hash] a hash of next states from this state
    # @param valid [Boolean] whether or not this is an accepting state
    # @example
    #   State.new('A', { :a => 'B', :b => 'A' }, true)
    def initialize(name, paths, accepting)
      @name = name
      @paths = paths
      @accepting = accepting
    end

    # Evaluates a string at this state, and passes the next string to the next state.
    #
    # @param string [String] the string to evaluate
    # @param fa [FiniteAutomata] the finite automata that this state belongs to
    def evaluate(string, fa)
      output = ""
      if (string.first.empty?)
        output << "#{@name} (#{@accepting ? 'accepting'.colorize(:green) : 'not accepting'.colorize(:red)}) "
        return { :output => output, :accepting => @accepting }
      end
      output << "#{@name} #{'->'.colorize(:light_black)} "
      
      next_state  = fa.get_state(paths[string.first.to_sym])
      next_string = string.shift_left
      result = next_state.evaluate(next_string, fa)
      output << result[:output]
      return { :output => output, :accepting => result[:accepting] }
    end
  end
end
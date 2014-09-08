module Fae

  # A state in the state diagram.
  class State
    attr_accessor :name, :next_states, :valid

    # Creates a new state instance.
    #
    # @param name [String] the state name, i.e.: "A"
    # @param next_states [Hash] a hash of next states from this state
    # @param valid [Boolean] whether or not this is an accepting state
    # @example
    #   State.new('A', { :a => 'B', :b => 'A' }, true)
    def initialize(name, next_states, valid)
      @name = name
      @next_states = next_states
      @valid = valid
    end

    # Evaluates a string at this state, and passes it to the next state.
    #
    # @param string [String] the string to evaluate
    # @param fa [FiniteAutomata] the finite automata that this state belongs to
    def evaluate(string, fa)
      if (string.first.empty?)
        output = @valid ? "valid".colorize(:green) : "invalid".colorize(:red)
        print "#{@name} (#{output}) "
        return { :output => output, :valid => @valid }
      end
      print "#{@name} #{'->'.colorize(:light_black)} "
      fa.get_state(next_states[string.first.to_sym]).evaluate(string.shift_left, fa)
    end
  end
end
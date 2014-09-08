module Fae
  class State
    attr_accessor :name, :next_states, :valid

    def initialize(name, next_states, valid)
      @name = name
      @next_states = next_states
      @valid = valid
    end

    def evaluate(string, fa)
      if (string.first.empty?)
        output = valid ? "valid".colorize(:green) : "invalid".colorize(:red)
        print "#{@name} (#{output}) "
        return { :output => output, :valid => valid }
      end
      print "#{@name} #{'->'.colorize(:light_black)} "
      fa.get_state(next_states[string.first.to_sym]).evaluate(string.shift_left, fa)
    end
  end
end
module Fae

  # The main class that drives the Finite Automata evaluation.
  #
  # Takes in a language, states, and strings, and checks them
  # to validate a state diagram.
  class FiniteAutomata
    attr_reader :language, :description, :states, :strings
    
    # Initializes a new instance of the FiniteAutomata.
    #
    # @param language [Language] a language instance
    # @param description [String] the description of the finite automata  
    def initialize(language, description)
      @states = []
      @strings = []
      @invalids = []
      @language = language
      @description = description
    end

    # Adds strings to check against when evaluating.
    #
    # @param strings [Array] an array of strings
    def add_strings(strings)
      strings.each do |string|
        @strings << string
      end
    end

    # Adds a single string to the strings array.
    #
    # @param string [String] the string to add
    def add_string(string)
      @strings << string
    end
    
    # Adds strings to check against when evaluating.
    #
    # @param states [Array] an array of states
    def add_states(states)
      states.each do |state|
        add_state(state)
      end
    end

    # Retrieves a state from this finite automata by name.
    #
    # @param name [String] the name of the state to find
    def get_state(name)
      retrieved_state = nil
      @states.each do |state|
        if (state.name == name)
          retrieved_state = state
          break
        end
      end
      if (retrieved_state.nil?)
        raise "State #{name} was not found in this Finite Automata. Ensure that all states have outputs for #{@language.characters}"
      end
      return retrieved_state
    end

    # Generates the finite automata for the intersection
    # of two different finite automatas.
    #
    # @param fa [FiniteAutomata] the finite automata to intersect this one with
    def intersection(fa)
      if (@language.characters.uniq.sort != fa.language.characters.uniq.sort)
        puts "Intersection currently requires the languages to be the same.".colorize(:red)
        return 
      end
      i_states  = []
      i_strings = []
      i_description = "the intersection of #{@description} and #{fa.description}"
      i_fa = FiniteAutomata.new(@language, i_description)

      @states.each do |state|
        fa.states.each do |fa_state|
          name = state.name + fa_state.name
          accepting = false
          paths = {}
          state.paths.keys.each do |key|
            path = state.paths[key] + fa_state.paths[key]
            paths[key] = path
          end
          if (state.accepting && fa_state.accepting)
            accepting = true
          end
          i_states << State.new(name, paths, accepting)
        end
      end

      i_fa.add_states(i_states)
      return i_fa
    end

    # Runs the evaluation on the finite automata.
    def evaluate!
      @invalids = []
      if (@states.length == 0)
        raise "You must add some states to your Finite Automata before checking strings"
      end

      puts """Evaluating strings for #{@description} using language #{@language.characters}".colorize(:yellow)
      @strings.each do |string|
        valid = evaluate_string(string)
        if (!valid)
          @invalids << string
        end
      end

      num_invalid = @invalids.length
      if (num_invalid > 0)
        puts "State diagram may be incorrect for #{@description}".colorize(:red)
        puts "\nA total of #{num_invalid} string#{'s' if num_invalid != 1} did not meet your expectations:\n"

        @invalids.each do |string|
          expected_string = string.expected ? "valid".colorize(:green) : "invalid".colorize(:red)
          puts "* You expected the string '#{string.colorize(:blue)}' to be #{expected_string}"
        end
        puts "\nIf these expectations are correct, then your state diagram needs revising. Otherwise, you've simply expected the wrong values."
      else
        puts "State diagram is correct.".colorize(:green)
      end
      puts
    end

    def to_s
      output = ""
      output << "Description: ".colorize(:yellow) + @description
      output << "\nLanguage: ".colorize(:yellow) + language.characters.to_s
      output << "\nStates:".colorize(:yellow)
      @states.each do |state|
        output << "\n  State #{state.name}: ".colorize(:blue)
        state.paths.keys.each do |key|
          output << "\n    #{'~'.colorize(:yellow)} #{key} #{'->'.colorize(:light_black)} #{state.paths[key]}"
        end
        accepting = state.accepting ? "accepting".colorize(:green) : "not accepting".colorize(:red)
        output << "\n    #{'~'.colorize(:yellow)} #{accepting}"
      end
      return output
    end

  private
    def add_state(new_state)
      valid = true
      @states.each do |state|
        if (new_state.name == state.name)
          raise 'Duplicate state added for Finite Automata'
        end
      end
      @states << new_state
    end

    def evaluate_string(string)
      print "#{string.colorize(:blue)}: "
      if (@language.string_is_valid(string))
        result = @states.first.evaluate(string, self)
        if (result[:accepting] != string.expected)
          puts "\u2717".encode("utf-8").colorize(:red)
          return false
        else
          puts "\u2713".encode("utf-8").colorize(:green)
          return true
        end
      else
        puts "not valid for language #{@characters}".colorize(:red)
        return true
      end
    end
  end
end
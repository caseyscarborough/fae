module Fae

  # The main class that drives the Finite Automata evaluation.
  #
  # Takes in a language, states, and strings, and checks them
  # to validate a state diagram.
  class FiniteAutomata
    attr_reader :language, :description, :states, :strings
    attr_accessor :valid_block
    
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

    def add_state(new_state)
      valid = true
      @states.each do |state|
        if (new_state.name == state.name)
          raise Fae::DuplicateStateException, 'Duplicate state added for Finite Automata'
        end
      end
      @states << new_state
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
        raise Fae::StateNotFoundException, "State #{name} was not found in this Finite Automata. Ensure that all states have outputs for #{@language.characters}"
      end
      return retrieved_state
    end

    # Generates the finite automata for the intersection
    # of two different finite automatas.
    #
    # @param fa [FiniteAutomata] the finite automata to intersect this one with
    def intersection(fa)
      perform_set_operation(:intersection, fa)
    end

    # Generates the finite automata for the union
    # of two different finite automatas.
    #
    # @param fa [FiniteAutomata] the finite automata to union this one with
    def union(fa)
      perform_set_operation(:union, fa)
    end

    # Generates the finite automata for the difference
    # of two different finite automatas.
    #
    # @param fa [FiniteAutomata] the finite automata to difference this one with
    def difference(fa)
      perform_set_operation(:difference, fa)
    end

    # Runs the evaluation on the finite automata.
    def evaluate!(suppress_output=false)
      output = ""
      @invalids = []
      if (@states.length == 0)
        raise Fae::EmptyStatesException, 'You must add some states to your Finite Automata before checking strings'
      end

      output << "Evaluating strings for #{@description} using language #{@language.characters}".colorize(:yellow)
      @strings.each do |string|
        result = evaluate_string(string)
        if (!result[:valid])
          @invalids << string
        end
        output << result[:output]
      end

      num_invalid = @invalids.length
      valid = num_invalid == 0
      if (!valid)
        output << "\nState diagram may be incorrect for #{@description}".colorize(:red)
        output << "\n\nA total of #{num_invalid} string#{'s' if num_invalid != 1} did not meet your expectations:\n"

        @invalids.each do |string|
          expected_string = string.expected ? "valid".colorize(:green) : "invalid".colorize(:red)
          output << "\n* You expected the string '#{string.colorize(:blue)}' to be #{expected_string}"
        end
        output << "\n\nIf these expectations are correct, then your state diagram needs revising. Otherwise, you've simply expected the wrong values."
      else
        output << "\nState diagram is correct.\n".colorize(:green)
      end

      if (!suppress_output)
        puts output
      end
      return valid
    end

    def generate_strings(number, length)
      if valid_block.nil?
        raise Fae::MissingValidBlockException, 'You must set the valid block for the Finite Automata to generate strings'
      end

      strings = []
      number.times do
        string = ""
        length.times { string << @language.characters.sample }
        strings << String.new(string, valid_block.call(string))
      end
      add_strings(strings)
      strings
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
    def perform_set_operation(type, fa)
      if (@language.characters.uniq.sort != fa.language.characters.uniq.sort)
        puts "Performing the #{type.to_s} requires the languages to be the same.".colorize(:red)
        return 
      end
      i_states  = []
      i_strings = []
      i_description = "the #{type.to_s} of #{@description} and #{fa.description}"
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
          if ((type == :intersection && (state.accepting && fa_state.accepting)) || 
              (type == :difference && (state.accepting && !fa_state.accepting )) ||
              (type == :union && (state.accepting || fa_state.accepting)))
            accepting = true
          end
          i_states << State.new(name, paths, accepting)
        end
      end

      i_fa.add_states(i_states)
      return i_fa
    end

    def evaluate_string(string)
      output = "\n#{string.colorize(:blue)}: "
      if (@language.string_is_valid(string))
        result = @states.first.evaluate(string, self)
        output << result[:output]
        if (result[:accepting] != string.expected)
          output << "\u2717".encode("utf-8").colorize(:red)
          return { :valid => false, :output => output }
        else
          output << "\u2713".encode("utf-8").colorize(:green)
          return { :valid => true, :output => output }
        end
      else
        output << "not valid for language #{@characters}".colorize(:red)
        return { :valid => true, :output => output }
      end
    end
  end
end
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
      strings.each { |string| @strings << string }
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
      states.each { |state| add_state(state) }
    end

    # Adds a single state to the states array.
    #
    # @param new_state [State] the state to add.
    def add_state(new_state)
      valid = true
      @states.each do |state|
        raise Fae::DuplicateStateException, 'Duplicate state added for Finite Automata' if new_state.name == state.name
      end
      @states << new_state
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
      retrieved_state
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
      raise Fae::EmptyStatesException, 'You must add some states to your Finite Automata before checking strings' if @states.length == 0

      output = "Evaluating strings for #{@description} using language #{@language.characters}".colorize(:yellow)
      @invalids = []

      @strings.each do |string|
        result = evaluate_string(string)
        @invalids << string if !result[:valid]
        output    << result[:output]
      end

      num_invalid = @invalids.length
      valid = num_invalid == 0
      if !valid
        output << "\nState diagram may be incorrect for #{@description}\n".colorize(:red)
        output << "\nA total of #{num_invalid} string#{'s' if num_invalid != 1} did not meet your expectations:\n\n"

        @invalids.each do |string|
          expected_string = string.expected ? "valid".colorize(:green) : "invalid".colorize(:red)
          output << "* You expected the string '#{string.colorize(:blue)}' to be #{expected_string}\n"
        end
        output << "\nIf these expectations are correct, then your state diagram needs revising. Otherwise, you've simply expected the wrong values."
      else
        output << "\nState diagram is correct.\n".colorize(:green)
      end

      if (!suppress_output)
        puts output
      end
      valid
    end

    # Generates strings for the finite automata and adds them
    # to the strings array.
    #
    # @param number [Integer] number of strings
    # @param length [Integer] length of each string
    def generate_strings(number, length)
      raise Fae::MissingValidBlockException, 'You must set the valid block for the Finite Automata to generate strings' if valid_block.nil?
      
      strings = []
      number.times do
        string = ""
        length.times { string << @language.characters.sample }
        strings << String.new(string, valid_block.call(string))
      end
      self.add_strings(strings)
      strings
    end

    def to_s
      output =  "Description: ".colorize(:yellow) + @description
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
      output
    end

  private
    def perform_set_operation(type, fa)
      if @language.characters.uniq.sort != fa.language.characters.uniq.sort
        raise LanguageMismatchException, "Performing the #{type.to_s} requires the languages to be the same.".colorize(:red)
      end

      states  = []
      strings = []
      description = "the #{type.to_s} of #{@description} and #{fa.description}"
      new_fa = FiniteAutomata.new(@language, description)

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
          states << State.new(name, paths, accepting)
        end
      end

      new_fa.add_states(states)
      new_fa
    end

    def evaluate_string(string)
      valid = true
      output = "\n#{string.colorize(:blue)}: "
      if (@language.string_is_valid(string))
        result = @states.first.evaluate(string, self)
        output << result[:output]
        if (result[:accepting] != string.expected)
          output << "\u2717".encode("utf-8").colorize(:red)
          valid = false
        else
          output << "\u2713".encode("utf-8").colorize(:green)
        end
      else
        output << "not valid for language #{@characters}".colorize(:red)
      end
      return { :valid => valid, :output => output }
    end
  end
end
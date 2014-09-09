require 'colorize'

# Fae classes
require_relative 'string'
require_relative 'fae/exceptions'
require_relative 'fae/language'
require_relative 'fae/state'
require_relative 'fae/finite_automata'
require_relative 'fae/version'

module Fae

  class << self
    def file_mode(filename)
      diagrams = nil
      begin
        diagrams = YAML.load_file(filename)
      rescue Exception => e
        abort "No such file: #{filename}"
      end

      diagrams.each do |diagram|
        language = diagram["language"].split(',')
        language.map(&:strip!)
        lang = Fae::Language.new(language)
        fa = Fae::FiniteAutomata.new(lang, diagram["description"])

        states = []
        diagram["states"].keys.each do |state|
          name = state
          values = diagram["states"][name].split(",")
          values.map(&:strip!)

          paths = {}
          values.each do |value|
            match = value.split("->")
            match.map(&:strip!)
            if (match)
              paths[match[0].to_sym] = match[1]
            end
          end
          states << Fae::State.new(name, paths, values[-1] == "accepting")        
        end

        strings = []
        diagram["strings"].keys.each do |string|
          value = string
          valid = diagram["strings"][string] == "valid"
          strings << String.new(value.dup, valid)
        end

        fa.add_states(states)
        fa.add_strings(strings)
        fa.evaluate!
      end
    end

    def interactive_mode
      states  = []
      strings = []

      print "~ Enter the letters of your language separated by a comma: ".colorize(:yellow)
      letters = gets.chomp.split(",")
      letters.map(&:strip!)

      language = Language.new(letters)
      print "~ Enter the description of your state diagram: ".colorize(:yellow)
      description = gets.chomp

      fa = FiniteAutomata.new(language, description)
      print "~ Enter your state names separated by a comma: ".colorize(:yellow)
      state_names = gets.chomp.split(",")
      state_names.map(&:strip!)

      state_names.each do |state|
        paths = {}
        puts "\nState #{state}:".colorize(:blue)

        letters.each do |letter|
          valid = false
          while (!valid)
            print "~ In state ".colorize(:yellow) + state.colorize(:blue) + " the letter ".colorize(:yellow) + letter.colorize(:blue) + " will take you to what state? ".colorize(:yellow)
            next_state = gets.chomp
            if (!state_names.include?(next_state))
              puts "State #{next_state} is not one of your state names. Please choose from the following: #{state_names}".colorize(:red)
            else
              paths[letter.to_sym] = next_state
              valid = true
            end
          end
        end

        print "~ Is state ".colorize(:yellow) + state.colorize(:blue) + " an accepting state? (y/n): ".colorize(:yellow)
        accepting = gets.chomp.casecmp('y').zero?
        states << State.new(state, paths, accepting)
      end

      finished = false
      string_values = []
      puts "~ Enter strings to test your state diagram with (type 'done' when finished):".colorize(:yellow)

      while(!finished)
        value = gets.chomp
        if (value == 'done')
          finished = true
        else
          string_values << value
        end
      end

      string_values.each do |value|
        print "~ Is ".colorize(:yellow) + value.colorize(:blue) + " a valid string for this state diagram? (y/n): ".colorize(:yellow)
        valid = gets.chomp.casecmp('y').zero?
        strings << String.new(value, valid)
      end
      puts

      fa.add_states(states)
      fa.add_strings(strings)
      fa.evaluate!
    end

  end
end

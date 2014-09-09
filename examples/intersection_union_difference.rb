#!/usr/bin/env ruby
#
# This script demonstrates the usage of the fae API and 
# checks the state diagram for the intersection, union,
# and difference of the following two languages:
#
# - The language of all strings with an odd number of a's
# - The language of all strings that include the substring 'bb'
#
require_relative '../lib/fae'

CHARACTERS = ['a', 'b']
LANGUAGE = Fae::Language.new(CHARACTERS)

states = {}

# Checks if the given string has an odd number of a's
def string_has_odd_number_of_the_letter_a(string)
  return (string.gsub('b', '').length % 2 == 1)
end

# Checks if the given string has the bb substring
def string_has_bb_substring(string)
  match = string.match(/bb/)
  if (match)
    return true
  end
  return false
end

# Checks if the string is valid for the intersection of the two languages
def valid_for_intersection(string)
  return string_has_odd_number_of_the_letter_a(string) && string_has_bb_substring(string)
end

# Checks if the string is valid for the union of the two languages
def valid_for_union(string)
  return string_has_odd_number_of_the_letter_a(string) || string_has_bb_substring(string)
end

# Checks if the string is valid for the difference of the two languages
def valid_for_difference(string)
  return string_has_odd_number_of_the_letter_a(string) && !string_has_bb_substring(string)
end

# Returns 100 random strings in the language, 50 of length 15 and 50 of length 5.
def get_random_strings
  strings = []

  50.times do
    string = ""
    15.times { string << CHARACTERS.sample }
    strings << string
  end

  50.times do
    string = ""
    5.times { string << CHARACTERS.sample }
    strings << string
  end
  return strings
end

# Turns a hash into an array (drops keys)
def get_array_from_hash(states)
  states_array = []
  states.keys.each do |key|
    states_array << states[key]
  end
  return states_array
end

###################
# Intersection

description = <<-DESC
The intersection of the language all strings that
have an odd number of a's and the language of all
strings that includes the substring 'bb'
DESC

intersection = Fae::FiniteAutomata.new(LANGUAGE, description)

# For intersection, BE is the only accepting state.
states[:AC] = Fae::State.new('AC', {:a => 'BC', :b => 'AD'}, false)
states[:AD] = Fae::State.new('AD', {:a => 'BC', :b => 'AE'}, false)
states[:AE] = Fae::State.new('AE', {:a => 'BE', :b => 'AE'}, false)
states[:BC] = Fae::State.new('BC', {:a => 'AC', :b => 'BD'}, false)
states[:BD] = Fae::State.new('BD', {:a => 'AC', :b => 'BE'}, false)
states[:BE] = Fae::State.new('BE', {:a => 'AE', :b => 'BE'}, true)

get_random_strings.each { |s| intersection.add_string(String.new(s, valid_for_intersection(s))) }
intersection.add_states(get_array_from_hash(states))
intersection.evaluate!

###################
# Union

description = <<-DESC
The union of the language all strings that
have an odd number of a's and the language of all
strings that includes the substring 'bb'
DESC

union = Fae::FiniteAutomata.new(LANGUAGE, description)

# For union, BC, AE, BD, and BE are accepting states
states[:BC].valid = true
states[:AE].valid = true
states[:BD].valid = true
# state_BE is alread valid

get_random_strings.each { |s| union.add_string(String.new(s, valid_for_union(s))) }
union.add_states(get_array_from_hash(states))
union.evaluate!

###################
# Difference

description = <<-DESC
The difference of the language all strings that
have an odd number of a's and the language of all
strings that includes the substring 'bb'
DESC

difference = Fae::FiniteAutomata.new(LANGUAGE, description)

# For difference, BC and BD are accepting states
states[:AE].valid = false
states[:BE].valid = false

get_random_strings.each { |s| difference.add_string(String.new(s, valid_for_difference(s))) }
difference.add_states(get_array_from_hash(states))
difference.evaluate!
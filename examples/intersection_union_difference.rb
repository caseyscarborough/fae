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

def string_has_odd_number_of_the_letter_a?(string)
  string.gsub('b', '').length % 2 == 1
end

def string_has_bb_substring?(string)
  !string.match(/bb/).nil?
end

fa_1 = Fae::FiniteAutomata.new(LANGUAGE, "the language of all strings where the number of a's is odd")
fa_2 = Fae::FiniteAutomata.new(LANGUAGE, "the language of all strings that include the substring 'bb'")

# These states were determined by drawing the state diagram language 1.
fa_1.add_states([
  Fae::State.new('A', { :a => 'B', :b => 'A' }, false),
  Fae::State.new('B', { :a => 'A', :b => 'B' }, true),
])

# These states were determined by drawing the state diagram for language 2.
fa_2.add_states([
  Fae::State.new('C', { :a => 'C', :b => 'D' }, false),
  Fae::State.new('D', { :a => 'C', :b => 'E' }, false),
  Fae::State.new('E', { :a => 'E', :b => 'E' }, true),
])

# Perform the intersection
intersection = fa_1.intersection(fa_2)
intersection.valid_block = lambda do |string|
  string_has_odd_number_of_the_letter_a?(string) && string_has_bb_substring?(string)
end
intersection.generate_strings(100, 10).evaluate!

# Perform the union
union = fa_1.union(fa_2)
union.valid_block = lambda do |string|
  string_has_odd_number_of_the_letter_a?(string) || string_has_bb_substring?(string)
end
union.generate_strings(100, 10).evaluate!

# Perform the difference
difference = fa_1.difference(fa_2)
difference.valid_block = lambda do |string|
  string_has_odd_number_of_the_letter_a?(string) && !string_has_bb_substring?(string)
end
difference.generate_strings(100, 10).evaluate!

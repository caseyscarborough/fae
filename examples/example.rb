require 'fae'

characters = ['a', 'b']
language = Language.new(characters)

# A Finite Automata is created with a language and description.
fa = FiniteAutomata.new(language, "The language of all strings containing at least two a's")

fa.add_states([
  # A new state is created with a name, a Hash of paths,
  # and whether or not it is accepting. The hash of paths
  # takes the letter as a key, and the next state as its value.
  State.new('A', { :a => 'B', :b => 'A' }, false),
  State.new('B', { :a => 'C', :b => 'B' }, false),
  State.new('C', { :a => 'C', :b => 'C' }, true)
])

fa.add_strings([
  # Strings are added with their value, and whether or
  # not they should be valid for this Finite Automata.
  String.new("a", false),
  String.new("aa", true),
  String.new("ba", false),
  # ... as many strings as you'd like to test
])

# Run the evaluation
fa.evaluate!
require_relative '../lib/fae'

CHARACTERS = ['a', 'b', 'c', 'd']
LANGUAGE   = Fae::Language.new(CHARACTERS)

# Patch the string class to make valid lambdas easier to read.
class String
  def has_at_least_three_cs?
    self.length - 3 >= self.gsub('c', '').length
  end

  def has_abcd_substring?
    !self.match(/abcd/).nil?
  end
end

def print_valid_message(valid)
  message = valid ? "VALID".colorize(:green) : "INVALID".colorize(:red)
  puts message
end

def run_validation(fa, block)
  fa.valid_block = block
  valid = fa.generate_strings(100, 20).evaluate!(true)
  print_valid_message(valid)
end

# Language 1
#
# The first Finite Automata is the language of all
# strings that contain the substring 'abcd'.
#
fa_1 = Fae::FiniteAutomata.new(LANGUAGE, "the language of all strings that contain the substring 'abcd'")

states = [
  { :name => 'A', :paths => { :a => 'B', :b => 'A', :c => 'A', :d => 'A'}, :accepting => false },
  { :name => 'B', :paths => { :a => 'B', :b => 'C', :c => 'A', :d => 'A'}, :accepting => false },
  { :name => 'C', :paths => { :a => 'B', :b => 'A', :c => 'D', :d => 'A'}, :accepting => false },
  { :name => 'D', :paths => { :a => 'B', :b => 'A', :c => 'A', :d => 'E'}, :accepting => false },
  { :name => 'E', :paths => { :a => 'E', :b => 'E', :c => 'E', :d => 'E'}, :accepting => true },
]
states.each { |s| fa_1.add_state(Fae::State.new(s[:name], s[:paths], s[:accepting])) }
run_validation(fa_1, lambda { |string| !string.match(/abcd/).nil? })

# Language 2
#
# The second Finite Automata is the language of all
# strings that contain more than three c's
#
fa_2 = Fae::FiniteAutomata.new(LANGUAGE, "the language of all strings that contain more than 3 c's")

states = [
  { :name => 'F', :paths => { :a => 'F', :b => 'F', :c => 'G', :d => 'F' }, :accepting => false },
  { :name => 'G', :paths => { :a => 'G', :b => 'G', :c => 'H', :d => 'G' }, :accepting => false },
  { :name => 'H', :paths => { :a => 'H', :b => 'H', :c => 'I', :d => 'H' }, :accepting => false },
  { :name => 'I', :paths => { :a => 'I', :b => 'I', :c => 'I', :d => 'I' }, :accepting => true },
]
states.each { |s| fa_2.add_state(Fae::State.new(s[:name], s[:paths], s[:accepting])) }
run_validation(fa_2, lambda { |string| string.length - 3 >= string.gsub('c', '').length })

# Intersection
intersection = fa_1.intersection(fa_2)
run_validation(
  intersection, lambda { |s| s.has_abcd_substring? && s.has_at_least_three_cs? }
)

# Union
union = fa_1.union(fa_2)
run_validation(
  union, lambda { |s| s.has_abcd_substring? || s.has_at_least_three_cs? }
)

# Difference
difference = fa_1.difference(fa_2)
run_validation(
  difference, lambda { |s| s.has_abcd_substring? && !s.has_at_least_three_cs? }
)
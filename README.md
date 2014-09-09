# Fae

[![Gem Version](https://badge.fury.io/rb/fae.svg)](http://badge.fury.io/rb/fae)

This is a small Ruby gem that evaluates a Finite Automata State Diagram for validity, and can generate Finite Automata from set operations of two or more different Finite Automata.

The gem currently only handles Deterministic Finite Automata.

## Dependencies

* Ruby 1.9.3 or greater

## Installation

Install the gem by running the following command:

```bash
gem install fae
```

## Evaluating a Diagram

The gem comes with an executable, `fae`, and can be run in two different modes, interactive or file.

### File Mode

You can load a finite automata state diagram from a file, by creating it in the following format:

```yaml
- description: the language with an odd number of a's
  # Comma-separated list of letters in your language
  language: a
  states:
    # This is the state name, then the paths each letter would take you.
    # This should be in "letter -> State, letter -> State" format.
    A: a -> B
    # If the state is accepting, you should add accepting to the end
    B: a -> A, accepting
  # Strings to evaluate when checking the state diagram
  strings:
    # In the format "name: valid or invalid"
    a: valid
    aa: invalid
    aaa: valid
    aaaa: invalid
```

Then run the executable with the `-f` flag:

```bash
fae -f diagram.yml
```

For example, take the following state diagram, which is the language `a,b` and described by `the language of all strings in which the number of a's is even`:

![Example State Diagram](https://raw.githubusercontent.com/caseyscarborough/fae/master/etc/example_state_diagram.png)

The data file for this diagram would look like this (`example.yml`):

```yaml
- description: the language of all strings in which the number of a's is even
  language: a, b
  states:
    A: a -> B, b -> A, accepting
    B: a -> A, b -> B
  strings:
    a: invalid
    aa: valid
    aaa: invalid
    baba: valid
    bababa: invalid
    bab: invalid
    # As many other string combinations you'd like to test
```

You can then run:

```bash
fae -f example.yml
```

And the output would be the following:

![Example Output](https://raw.githubusercontent.com/caseyscarborough/fae/master/etc/example_file_mode_output.png)

## Interactive Mode

Interactive mode is exactly what it sounds like, in which it will ask you questions about your diagram and evaluate it for you. This method is convenient, but if you'd like to check it again you will have to go back through the entire process.

You can start interactive mode by executing:

```bash
fae -i
```

Here is an example output:

![Example Output](https://raw.githubusercontent.com/caseyscarborough/fae/master/etc/example_interactive_mode_output.png)

## Using the API

You can also use the library directly if you'd rather run your own scripts.

### Basic Usage

```rb
require 'fae'

characters = ['a', 'b']
language = Fae::Language.new(characters)

# A Finite Automata is created with a language and description.
fa = Fae::FiniteAutomata.new(language, "The language of all strings containing at least two a's")

fa.add_states([
  # A new state is created with a name, a Hash of paths,
  # and whether or not it is accepting. The hash of paths
  # takes the letter as a key, and the next state as its value.
  Fae::State.new('A', { :a => 'B', :b => 'A' }, false),
  Fae::State.new('B', { :a => 'C', :b => 'B' }, false),
  Fae::State.new('C', { :a => 'C', :b => 'C' }, true)
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

# Run the evaluation with no output
valid = fa.evaluate!(true)
puts "Diagram is correct" if valid
```

### Generating Tests for your State Diagram

If you really want to test your diagram and don't want to have to come up with all of your valid or invalid strings, you can generate valid and invalid strings by setting the `valid_block` as a lambda returning a boolean expression on your Finite Automata that represents a valid string in the language.

For example, in the language of all strings that have an odd number of a's, the following code would represent a valid string:

```ruby
# If the value is one when we take away all b's and mod the 
# length by two, then we had an odd number of a's
string.gsub('b', '').length % 2 == 1
```

Here is a full example that would test 1000 strings against your diagram:

```ruby
language = Fae::Language.new(['a', 'b'])
fa = Fae::FiniteAutomata.new(language, "strings that have an odd number of a's")

# Set the valid block
fa.valid_block = lambda { |string| string.gsub('b', '').length % 2 == 1 }

# Generate 1000 strings of length 20 and evaluate:
fa.generate_strings(1000, 20)
fa.evaluate!
```

For more examples, see [`examples/advanced.rb`](https://github.com/caseyscarborough/fae/blob/master/examples/advanced.rb)

## When Your State Diagram is Incorrect

If your state diagram is incorrect, the program will give you feedback about your diagram:

![](https://raw.githubusercontent.com/caseyscarborough/fae/master/etc/example_failed_output.png)

This can help you figure out where your diagram is going wrong.

## Generating a Diagram

You can use the gem to generate the union, intersection, or difference of two state diagrams. See the following:

```ruby
fa_1 = Fae::FiniteAutomata.new(LANGUAGE, "the language of all strings where the number of a's is odd")
fa_2 = Fae::FiniteAutomata.new(LANGUAGE, "the language of all strings that include the substring 'bb'")

# These states were determined by drawing the state diagram.
fa_1.add_states([
  Fae::State.new('A', { :a => 'B', :b => 'A' }, false),
  Fae::State.new('B', { :a => 'A', :b => 'B' }, true),
])

# These states were determined by drawing the state diagram.
fa_2.add_states([
  Fae::State.new('C', { :a => 'C', :b => 'D' }, false),
  Fae::State.new('D', { :a => 'C', :b => 'E' }, false),
  Fae::State.new('E', { :a => 'E', :b => 'E' }, true),
])

# Get the intersection, union, and difference of the two finite automata
intersection = fa_1.intersection(fa_2)
union        = fa_1.union(fa_2)
difference   = fa_1.difference(fa_2)
```

You can then output the new finite automata to see the states, paths, and accepting states:

```ruby
puts intersection
```

![Example Intersection Output](https://raw.githubusercontent.com/caseyscarborough/fae/master/etc/example_intersection_output.png)

See [`examples/intersection_union_difference.rb`](https://github.com/caseyscarborough/fae/blob/master/examples/intersection_union_difference.rb) for an example of generating the diagram and evaluating them.

## Examples

An example data file and direct API usage can be seen in the [examples directory](https://github.com/caseyscarborough/fae/tree/master/examples).

The examples in the data file are taken from the Chapter 2 exercises in [Introduction to Languages and the Theory of Computation](http://www.amazon.com/Introduction-Languages-Theory-Computation-Martin/dp/0073191469).

## Contributing

1. Fork it ( https://github.com/caseyscarborough/fae/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

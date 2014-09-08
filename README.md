# Fae

[![Gem Version](https://badge.fury.io/rb/fae.svg)](http://badge.fury.io/rb/fae)

This is a small Ruby gem that evaluates a Finite Automata State Diagram for validity.

## Installation

Install the gem by running the following command:

```bash
gem install fae
```

## Usage

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

You can also use the library directly if you'd rather run your own scripts. Here is an example usage:

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
```

## When Your State Diagram is Incorrect

If your state diagram is incorrect, the program will give you feedback about your diagram:

![](https://raw.githubusercontent.com/caseyscarborough/fae/master/etc/example_failed_output.png)

This can help you figure out where your diagram is going wrong.

## Examples

An example data file and direct API usage can be seen in the [examples directory](https://github.com/caseyscarborough/fae/tree/master/examples).

The examples in the data file are taken from the Chapter 2 exercises in [Introduction to Languages and the Theory of Computation](http://www.amazon.com/Introduction-Languages-Theory-Computation-Martin/dp/0073191469).

## Contributing

1. Fork it ( https://github.com/caseyscarborough/fae/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

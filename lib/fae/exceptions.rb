module Fae
  # Generic exception for the Fae library.
  class FaeException < StandardError; end

  # Raised when Finite Automata doesn't have a valid block
  # and strings are trying to be generated
  class MissingValidBlockException < FaeException; end

  # Raised when a state couldn't be found in a diagram,
  # which should never happen.
  class StateNotFoundException < FaeException; end

  # Raised when a duplicate state is trying to be added
  # to a FiniteAutomata.
  class DuplicateStateException < FaeException; end

  # Raised when trying to evaluate a FiniteAutomata
  # with no states.
  class EmptyStatesException < FaeException; end

  # Raised when trying to perform a set operation on
  # FiniteAutomata with two different languages.
  class LanguageMismatchException < FaeException; end
end
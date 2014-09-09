module Fae

  # A language described by any number of characters
  class Language
    attr_accessor :characters

    # Creates a new language instance.
    #
    # @param characters [Array] an array of characters
    def initialize(characters, valid_block=nil)
      @characters = []
      @characters = characters.uniq
    end

    # Checks if a string is valid for this language.
    #
    # @param string [String] the string to check
    def string_is_valid(string)
      # Use lookahead to check for valid string
      string.match "^(?=.*\\D)[#{@characters.join('|')}]+$"
    end

    # Adds a character to the language.
    #
    # @param char [String] the character to add
    def add_character(char)
      @characters << char
    end
  end
end
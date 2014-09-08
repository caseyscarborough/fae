module Fae
  class Language
    attr_accessor :characters

    def initialize(characters)
      @characters = []
      @characters = characters.uniq
    end

    def string_is_valid(string)
      # Use lookahead to check for valid string
      regex = "^(?=.*\\D)[#{@characters.join('|')}]+$"

      if (string.match /#{regex}/)
        return true
      end
      return false
    end

    def add_character(char)
      @characters << char
    end
  end
end
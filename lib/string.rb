# Used to add functionality to the Ruby String class.
class String
  attr_accessor :expected
  
  def self.new(value, expected)
    string = value
    string.expected = expected
    string
  end

  def first
    self[0, 1]
  end

  def shift_left(num = 1)
    self[num..-1]
  end
end
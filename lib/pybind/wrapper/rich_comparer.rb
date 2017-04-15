module PyBind
  module RichComparer
    Py_LT = 0
    Py_LE = 1
    Py_EQ = 2
    Py_NE = 3
    Py_GT = 4
    Py_GE = 5

    RICH_COMPARISON_OPCODES = {
      :<  => Py_LT,
      :<= => Py_LE,
      :== => Py_EQ,
      :!= => Py_NE,
      :>  => Py_GT,
      :>= => Py_GE
    }.freeze

    def rich_compare(other, op)
      opcode = RICH_COMPARISON_OPCODES[op]
      raise ArgumentError, "Unknown comparison op: #{op}" unless opcode

      other = Conversions.from_ruby(other)
      return other.null? if __pyobj__.null?
      return false if other.null?

      value = LibPython.PyObject_RichCompare(__pyobj__, other, opcode)
      raise "Unable to compare: #{self} #{op} #{other}" if value.null?
      value.to_ruby
    end

    RICH_COMPARISON_OPCODES.keys.each do |op|
      define_method(op) {|other| rich_compare(other, op) }
    end

  end
end

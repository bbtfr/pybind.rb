module PyBind
  module Operator
    BINARY_OPERATION_OPFUNCS = {
      :+ => :PyNumber_Add,
      :- => :PyNumber_Subtract,
      :* => :PyNumber_Multiply,
      :/ => :PyNumber_TrueDivide,
      :% => :PyNumber_Remainder,
      :<< => :PyNumber_Lshift,
      :>> => :PyNumber_Rshift,
      :& => :PyNumber_And,
      :^ => :PyNumber_Xor,
      :| => :PyNumber_Or
    }.freeze

    UNARY_OPERATION_OPFUNCS = {
      :+@ => :PyNumber_Positive,
      :-@ => :PyNumber_Negative,
      :~ => :PyNumber_Invert,
    }.freeze

    def __binary_operate__(other, op)
      opfunc = BINARY_OPERATION_OPFUNCS[op]
      raise ArgumentError, "Unknown binary operation op: #{op}" unless opfunc

      other = TypeCast.from_ruby(other)
      value = LibPython.send(opfunc, __pyref__, other)
      raise PyError.fetch if value.null?
      value.to_ruby
    end

    BINARY_OPERATION_OPFUNCS.keys.each do |op|
      define_method(op) do |other|
        __binary_operate__(other, op)
      end
    end

    def __unary_operate__(op)
      opfunc = UNARY_OPERATION_OPFUNCS[op]
      raise ArgumentError, "Unknown unary operation op: #{op}" unless opfunc

      value = LibPython.send(opfunc, __pyref__)
      raise PyError.fetch if value.null?
      value.to_ruby
    end

    UNARY_OPERATION_OPFUNCS.keys.each do |op|
      define_method(op) do |other|
        __unary_operate__(op)
      end
    end

    def **(other)
      other = TypeCast.from_ruby(other)
      value = LibPython.PyNumber_Power(__pyref__, other, PyBind.None)
      raise PyError.fetch if value.null?
      value.to_ruby
    end

    def <=>(other)
      if LibPython.respond_to? :PyObject_Compare
        other = TypeCast.from_ruby(other)
        value = LibPython.PyObject_Compare(__pyref__, other)
        raise PyError.fetch unless LibPython.PyErr_Occurred().null?
        value
      else
        (self > other) - (self < other)
      end
    end

    def ===(other)
      other = TypeCast.from_ruby(other)
      __pyref__.to_ptr == other.to_ptr
    end

    def !
      value = LibPython.PyObject_Not(__pyref__)
      raise PyError.fetch if value == -1
      value == 1
    end
  end
end

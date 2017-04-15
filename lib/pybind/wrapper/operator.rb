module PyBind
  module Operator
    BINARY_OPERATION_OPFUNCS = {
      :+  => :PyNumber_Add,
      :- => :PyNumber_Subtract,
      :* => :PyNumber_Multiply,
      :/ => :PyNumber_TrueDivide,
      :**  => :PyNumber_Power,
    }.freeze

    def __binary_operate__(other, op)
      opfunc = BINARY_OPERATION_OPFUNCS[op]
      raise ArgumentError, "Unknown binary operation op: #{op}" unless opfunc

      other = TypeCast.from_ruby(other)
      value = LibPython.send(opfunc, __pyref__, other)
      return value.to_ruby unless value.null?
      raise PyError.fetch
    end

    BINARY_OPERATION_OPFUNCS.keys.each do |op|
      define_method(op) do |other|
        __binary_operate__(other, op)
      end
    end
  end
end

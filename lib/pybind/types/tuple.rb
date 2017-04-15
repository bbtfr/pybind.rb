module PyBind
  class PyTuple
    include PyObjectWrapper
    pybind_type LibPython.PyTuple_Type

    def self.new(init)
      case init
      when Integer
        super(LibPython.PyTuple_New(init))
      when Array
        tuple = new(init.size)
        init.each_with_index do |obj, index|
          tuple[index] = obj
        end
        tuple
      when PyObjectRef
        super(init)
      end
    end

    # Make tuple from array
    def self.[](*ary)
      new(ary)
    end

    def size
      LibPython.PyTuple_Size(__pyref__)
    end

    def [](index)
      LibPython.PyTuple_GetItem(__pyref__, index).to_ruby
    end

    def []=(index, value)
      value = TypeCast.from_ruby(value)
      LibPython.PyTuple_SetItem(__pyref__, index, value)
    end

    def to_a
      size.times.map do |i|
        self[i]
      end
    end

    alias_method :to_ary, :to_a
  end
end

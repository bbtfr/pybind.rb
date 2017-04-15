module PyBind
  class PyTuple
    include PyArrayLike
    include PyObjectWrapper
    pybind_type LibPython.PyTuple_Type

    def self.new(init)
      case init
      when PyObjectRef
        super
      when Integer
        super(LibPython.PyTuple_New(init))
      when Array
        tuple = new(init.size)
        init.each_with_index do |obj, index|
          tuple[index] = obj
        end
        tuple
      else
        raise TypeError, "the argument must be an Integer, a PyObjectRef or a Array"
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
  end
end

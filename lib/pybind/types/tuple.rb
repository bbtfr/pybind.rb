require 'pybind/types/sequence'

module PyBind
  class PyTuple
    include PyObjectWrapper
    bind_pytype LibPython.PyTuple_Type

    include PySequence

    def self.new(init)
      case init
      when PyObjectStruct
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
        raise TypeError, "the argument must be an Integer, a PyObjectStruct or a Array"
      end
    end

    # Make tuple from array
    def self.[](*ary)
      new(ary)
    end

    def size
      LibPython.PyTuple_Size(@pystruct)
    end

    def [](index)
      LibPython.PyTuple_GetItem(@pystruct, index).to_ruby
    end

    def []=(index, value)
      value = value.to_python
      LibPython.PyTuple_SetItem(@pystruct, index, value)
    end
  end
end

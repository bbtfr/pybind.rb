module PyBind
  class PyList
    include PyArrayLike
    include PyObjectWrapper
    bind_pytype LibPython.PyList_Type

    bind_rbtype Array do |obj|
      PyList.new(obj).__pyref__
    end

    def self.new(init = nil)
      case init
      when PyObjectRef
        super
      when nil
        new(0)
      when Integer
        new(LibPython.PyList_New(init))
      when Array
        new.tap do |list|
          init.each do |item|
            list << item
          end
        end
      else
        raise TypeError, "the argument must be an Integer, a PyObjectRef or a Array"
      end
    end

    def <<(value)
      value = TypeCast.from_ruby(value)
      LibPython.PyList_Append(__pyref__, value)
      self
    end

    def size
      LibPython.PyList_Size(__pyref__)
    end
  end
end

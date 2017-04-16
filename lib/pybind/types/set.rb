module PyBind
  class PySet
    include PyObjectWrapper
    bind_pytype LibPython.PySet_Type

    def initialize(init)
      super
    end

    def size
      LibPython.PySet_Size(__pyref__)
    end

    def include?(obj)
      LibPython.PySet_Contains(__pyref__, TypeCast.from_ruby(obj)) == 1
    end
  end
end

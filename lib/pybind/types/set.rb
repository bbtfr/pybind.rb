module PyBind
  class PySet
    include PyObjectWrapper
    pybind_type LibPython.PySet_Type

    def initialize(init)
      super
    end

    def size
      LibPython.PySet_Size(@pystruct)
    end

    def include?(obj)
      obj = obj.to_python
      LibPython.PySet_Contains(@pystruct, obj) == 1
    end
  end
end

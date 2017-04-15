module PyBind
  class PyObject
    include PyObjectWrapper

    def self.null
      new(PyObjectRef.null)
    end
  end
end

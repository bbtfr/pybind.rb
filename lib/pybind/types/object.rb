module PyBind
  class PyObject
    include PyObjectWrapper

    def self.null
      new(PyObjectStruct.null)
    end
  end
end

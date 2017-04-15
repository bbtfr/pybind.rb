module PyBind
  class PyObject
    include PyObjectWrapper

    def self.null
      new(PyObjectRef.new(FFI::Pointer::NULL))
    end
  end
end

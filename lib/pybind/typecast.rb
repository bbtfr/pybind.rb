module PyBind
  module TypeCast
    def self.from_python(pyobj)
      pystruct = pyobj.to_python_struct
      return nil if pystruct.null? || pystruct.none?

      Types.pytypes.each do |pytype|
        return pytype.from_python(pystruct) if pytype.python_instance?(pystruct)
      end
      PyObject.from_python(pystruct)
    end

    def self.to_python_arguments(indices)
      if indices.length == 1
        indices = indices[0]
      else
        indices = PyCall.tuple(*indices)
      end
      indices.to_python
    end
  end

  class PyObjectStruct
    def to_ruby
      TypeCast.from_python(self)
    end
  end
end

module PyBind
  module TypeCast
    def self.to_ruby(pyobj)
      pyref = to_pyref(pyobj)
      return nil if pyref.null? || pyref.none?

      Types.pytypes.each do |pytype|
        return pytype.to_ruby(pyref) if pytype.pyinstance?(pyref)
      end
      PyObject.to_ruby(pyref)
    end

    def self.from_ruby(obj)
      case obj
      when PyObjectStruct, PyObjectWrapper, FFI::Pointer
        to_pyref(obj)
      when NilClass
        PyBind.None
      else
        Types.pytypes.each do |pytype|
          return pytype.from_ruby(obj) if pytype.rbinstance?(obj)
        end
        raise TypeError, "can not convert #{obj.inspect} to a PyObjectStruct"
      end
    end

    def self.to_pyref(obj)
      case obj
      when PyObjectStruct
        obj
      when PyObjectWrapper
        obj.__pyref__
      when FFI::Pointer
        PyObjectStruct.new(obj)
      else
        raise TypeError, "#{obj.inspect} is not a Python reference"
      end
    end

    def self.to_pyobj(obj)
      case obj
      when PyObjectWrapper
        obj
      when PyObjectStruct
        PyObject.new(obj)
      when FFI::Pointer
        PyObject.new(PyObjectStruct.new(obj))
      else
        raise TypeError, "#{obj.inspect} is not a Python object"
      end
    end

    def self.to_indices_pyref(indices)
      if indices.length == 1
        indices = indices[0]
      else
        indices = PyCall.tuple(*indices)
      end
      from_ruby(indices)
    end
  end

  class PyObjectStruct
    def to_ruby
      TypeCast.to_ruby(self)
    end
  end
end

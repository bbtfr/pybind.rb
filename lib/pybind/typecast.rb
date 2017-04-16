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
      when PyObjectRef, PyObjectWrapper, FFI::Pointer
        to_pyref(obj)
      when NilClass
        PyBind.None
      else
        Types.pytypes.each do |pytype|
          return pytype.from_ruby(obj) if pytype.rbinstance?(obj)
        end
        raise TypeError, "can not convert #{obj.inspect} to a PyObjectRef"
      end
    end

    def self.to_pyref(obj)
      case obj
      when PyObjectRef
        obj
      when PyObjectWrapper
        obj.__pyref__
      when FFI::Pointer
        PyObjectRef.new(obj)
      else
        raise TypeError, "#{obj.inspect} is not a Python reference"
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

  class PyObjectRef
    def to_ruby
      TypeCast.to_ruby(self)
    end
  end
end

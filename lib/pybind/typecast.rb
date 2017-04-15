module PyBind
  module TypeCast
    def self.to_ruby(pyobj)
      pyref = from_ruby(pyobj)
      return nil if pyref.null? || pyref.none?

      Types.pytypes.each do |pytype|
        return pytype.new(pyref) if pytype.is_instance?(pyref)
      end
      PyObject.new(pyref)
    end

    def self.from_ruby(obj)
      case obj
      when PyObjectRef
        obj
      when PyObjectWrapper
        obj.__pyref__
      when FFI::Pointer
        PyObjectRef.new(obj)
      when TrueClass, FalseClass
        LibPython.PyBool_FromLong(obj ? 1 : 0)
      when Integer
        LibPython.PyInt_FromSsize_t(obj)
      when Float
        LibPython.PyFloat_FromDouble(obj)
      when String
        case obj.encoding
        when Encoding::US_ASCII, Encoding::BINARY
          LibPython.PyString_FromStringAndSize(obj, obj.bytesize)
        else
          obj = obj.encode(Encoding::UTF_8)
          LibPython.PyUnicode_DecodeUTF8(obj, obj.bytesize, nil)
        end
      when Symbol
        from_ruby(obj.to_s)
      when Array
        PyList.new(obj).__pyref__
      when Hash
        PyDict.new(obj).__pyref__
      else
        raise ArgumentError, "can not convert #{obj.inspect} to a python reference"
      end
    end
  end

  class PyObjectRef
    def to_ruby
      TypeCast.to_ruby(self)
    end
  end
end

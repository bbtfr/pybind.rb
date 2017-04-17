class Object
  def to_python_struct
    raise TypeError, "can not convert #{inspect} to a PyObjectStruct"
  end
  alias_method :to_python, :to_python_struct
end

class NilClass
  def to_python
    PyBind::LibPython.Py_None
  end
end

class TrueClass
  def to_python
    PyBind::LibPython.Py_True
  end
end

class FalseClass
  def to_python
    PyBind::LibPython.Py_False
  end
end

class Integer
  def to_python
    PyBind::LibPython.PyInt_FromSsize_t(self)
  end
end

class Float
  def to_python
    PyBind::LibPython.PyFloat_FromDouble(self)
  end
end

class String
  def to_python
    case encoding
    when Encoding::US_ASCII, Encoding::BINARY
      PyBind::LibPython.PyString_FromStringAndSize(self, bytesize)
    else
      utf8_str = encode(Encoding::UTF_8)
      PyBind::LibPython.PyUnicode_DecodeUTF8(utf8_str, utf8_str.bytesize, nil)
    end
  end
end

class Symbol
  def to_python
    to_s.to_python
  end
end

class Hash
  def to_python
    PyBind::PyDict.new(self).to_python_struct
  end
end

class Array
  def to_python
    PyBind::PyList.new(self).to_python_struct
  end
end

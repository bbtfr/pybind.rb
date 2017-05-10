module PyBind
  class PyType
    include PyObjectWrapper
    pybind_type LibPython.PyType_Type

    def to_s
      return super unless has_attribute?('__name__')
      get_attribute('__name__')
    end

    def inspect
      return super unless has_attribute?('__name__')
      "#<PyType(#{get_attribute('__name__')})>"
    end
  end

  class PyString
    include PyObjectWrapper

    pybind_type LibPython.PyString_Type do |pystruct|
      FFI::MemoryPointer.new(:string) do |str_ptr|
        FFI::MemoryPointer.new(:int) do |len_ptr|
          res = LibPython.PyString_AsStringAndSize(pystruct, str_ptr, len_ptr)
          return nil if res == -1  # FIXME: error

          len = len_ptr.get(:int, 0)
          return str_ptr.get_pointer(0).read_string(len)
        end
      end
    end
  end

  class PyUnicode
    include PyObjectWrapper

    pybind_type LibPython.PyUnicode_Type do |pystruct|
      pystruct = LibPython.PyUnicode_AsUTF8String(pystruct)
      PyString.from_python(pystruct).force_encoding(Encoding::UTF_8)
    end
  end

  class PyInt
    include PyObjectWrapper

    pybind_type LibPython.PyInt_Type do |pystruct|
      LibPython.PyInt_AsSsize_t(pystruct)
    end
  end

  class PyBool
    include PyObjectWrapper

    pybind_type LibPython.PyBool_Type do |pystruct|
      LibPython.PyInt_AsSsize_t(pystruct) != 0
    end
  end

  class PyFloat
    include PyObjectWrapper

    pybind_type LibPython.PyFloat_Type do |pystruct|
      LibPython.PyFloat_AsDouble(pystruct)
    end
  end

  class PyComplex
    include PyObjectWrapper

    pybind_type LibPython.PyComplex_Type do |pystruct|
      real = LibPython.PyComplex_RealAsDouble(pystruct)
      imag = LibPython.PyComplex_ImagAsDouble(pystruct)
      Complex(real, imag)
    end
  end
end

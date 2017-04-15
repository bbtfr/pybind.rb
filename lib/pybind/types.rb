module PyBind
  module Types
    class << self
      attr_reader :pytypes
    end

    @pytypes ||= []
    def self.register_type(pytype)
      @pytypes << pytype
    end
  end

  class PyType
    include PyObjectWrapper
    pybind_type LibPython.PyType_Type

    def to_s
      get_attr('__name__')
    end
  end

  class PyString
    include PyObjectWrapper
    pybind_type LibPython.PyString_Type

    def self.new pyref
      FFI::MemoryPointer.new(:string) do |str_ptr|
        FFI::MemoryPointer.new(:int) do |len_ptr|
          res = LibPython.PyString_AsStringAndSize(pyref, str_ptr, len_ptr)
          return nil if res == -1  # FIXME: error

          len = len_ptr.get(:int, 0)
          return str_ptr.get_pointer(0).read_string(len)
        end
      end
    end
  end

  class PyUnicode
    include PyObjectWrapper
    pybind_type LibPython.PyUnicode_Type

    def self.new pyref
      pyref = LibPython.PyUnicode_AsUTF8String(pyref)
      return PyString.new(pyref).force_encoding(Encoding::UTF_8)
    end
  end

  class PyBool
    include PyObjectWrapper
    pybind_type LibPython.PyBool_Type

    def self.new pyref
      LibPython.PyInt_AsSsize_t(pyref) != 0
    end
  end

  class PyInt
    include PyObjectWrapper
    pybind_type LibPython.PyInt_Type

    def self.new pyref
      LibPython.PyInt_AsSsize_t(pyref)
    end
  end

  class PyFloat
    include PyObjectWrapper
    pybind_type LibPython.PyFloat_Type

    def self.new pyref
      LibPython.PyFloat_AsDouble(pyref)
    end
  end

  class PyComplex
    include PyObjectWrapper
    pybind_type LibPython.PyComplex_Type

    def self.new pyref
      real = LibPython.PyComplex_RealAsDouble(pyref)
      imag = LibPython.PyComplex_ImagAsDouble(pyref)
      Complex(real, imag)
    end
  end
end

require 'pybind/types/object'
require 'pybind/types/array_like'
require 'pybind/types/tuple'
require 'pybind/types/slice'
require 'pybind/types/list'
require 'pybind/types/dict'
require 'pybind/types/set'

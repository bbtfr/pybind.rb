module PyBind
  module Types
    class << self
      attr_reader :pytypes
    end

    @pytypes ||= []
    def self.register_type(pytype)
      @pytypes.unshift(pytype)
    end
  end

  class PyType
    include PyObjectWrapper
    bind_pytype LibPython.PyType_Type

    def to_s
      return super unless has_attr?('__name__')
      "PyType(#{get_attr('__name__')})"
    end
  end

  class PyString
    include PyObjectWrapper

    bind_pytype LibPython.PyString_Type do |pyref|
      FFI::MemoryPointer.new(:string) do |str_ptr|
        FFI::MemoryPointer.new(:int) do |len_ptr|
          res = LibPython.PyString_AsStringAndSize(pyref, str_ptr, len_ptr)
          return nil if res == -1  # FIXME: error

          len = len_ptr.get(:int, 0)
          return str_ptr.get_pointer(0).read_string(len)
        end
      end
    end

    bind_rbtype String do |obj|
      case obj.encoding
      when Encoding::US_ASCII, Encoding::BINARY
        LibPython.PyString_FromStringAndSize(obj, obj.bytesize)
      else
        obj = obj.encode(Encoding::UTF_8)
        LibPython.PyUnicode_DecodeUTF8(obj, obj.bytesize, nil)
      end
    end
  end

  class PyUnicode
    include PyObjectWrapper

    bind_pytype LibPython.PyUnicode_Type do |pyref|
      pyref = LibPython.PyUnicode_AsUTF8String(pyref)
      PyString.to_ruby(pyref).force_encoding(Encoding::UTF_8)
    end
  end

  class PySymbol
    include PyObjectWrapper

    bind_rbtype Symbol do |obj|
      PyString.from_ruby(obj.to_s)
    end
  end

  class PyInt
    include PyObjectWrapper

    bind_pytype LibPython.PyInt_Type do |pyref|
      LibPython.PyInt_AsSsize_t(pyref)
    end

    bind_rbtype Integer do |obj|
      LibPython.PyInt_FromSsize_t(obj)
    end
  end

  class PyBool
    include PyObjectWrapper

    bind_pytype LibPython.PyBool_Type do |pyref|
      p pyref
      LibPython.PyInt_AsSsize_t(pyref) != 0
    end

    bind_rbtype TrueClass, FalseClass do |obj|
      LibPython.PyBool_FromLong(obj ? 1 : 0)
    end
  end

  class PyFloat
    include PyObjectWrapper

    bind_pytype LibPython.PyFloat_Type do |pyref|
      LibPython.PyFloat_AsDouble(pyref)
    end

    bind_rbtype Float do |obj|
      LibPython.PyFloat_FromDouble(obj)
    end
  end

  class PyComplex
    include PyObjectWrapper

    bind_pytype LibPython.PyComplex_Type do |pyref|
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

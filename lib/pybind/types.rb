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
      "#{self.class}(#{get_attr('__name__')})"
    end
  end

  class PyString
    include PyObjectWrapper
    pybind_type LibPython.PyString_Type

    def self.new pyobj
      FFI::MemoryPointer.new(:string) do |str_ptr|
        FFI::MemoryPointer.new(:int) do |len_ptr|
          pyref = TypeCast.from_ruby(pyobj)
          res = LibPython.PyString_AsStringAndSize(pyref, str_ptr, len_ptr)
          return nil if res == -1  # FIXME: error

          len = len_ptr.get(:int, 0)
          return str_ptr.get_pointer(0).read_string(len)
        end
      end
    end
  end
end

require 'pybind/types/object'
require 'pybind/types/tuple'

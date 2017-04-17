require 'ffi'

module PyBind
  class PyObjectStruct < FFI::Struct
    layout ob_refcnt: :ssize_t,
           ob_type:   PyObjectStruct.by_ref

    def self.null
      new(FFI::Pointer::NULL)
    end

    def none?
      PyBind.None.to_ptr == to_ptr
    end

    def kind_of?(klass)
      case klass
      when PyBind::PyObjectStruct
        value = LibPython.PyObject_IsInstance(self, klass)
        raise PyError.fetch if value == -1
        value == 1
      else
        super
      end
    end

    def to_ruby_object
      PyObject.new(self)
    end
  end
end

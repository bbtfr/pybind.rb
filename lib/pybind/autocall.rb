require 'pybind/types/function'

module PyBind
  module PyObjectWrapper
    def autocall_method_missing(value, *args, **kwargs)
      case value
      when PyType, PyFunction, PyBuiltinFunction, PyMethod
        value.call(*args, **kwargs)
      else
        value
      end
    end
  end
end

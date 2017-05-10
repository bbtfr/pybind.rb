module PyBind
  module PyCallable
  end

  class PyFunction
    include PyCallable
    include PyObjectWrapper
    pybind_type PyBind.types.FunctionType
  end

  class PyMethod
    include PyCallable
    include PyObjectWrapper
    pybind_type PyBind.types.MethodType
  end

  class PyBuiltinFunction
    include PyCallable
    include PyObjectWrapper
    pybind_type PyBind.types.BuiltinFunctionType
  end

  class PyType
    include PyCallable
  end
end

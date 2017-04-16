module PyBind
  class PyFunction
    include PyObjectWrapper
    bind_pytype PyBind.types.FunctionType
  end
end

module PyBind
  class PyBuiltinFunction
    include PyObjectWrapper
    bind_pytype PyBind.types.BuiltinFunctionType
  end
end

module PyBind
  class PyMethod
    include PyObjectWrapper
    bind_pytype PyBind.types.MethodType
  end
end

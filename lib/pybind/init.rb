module PyBind
  private_class_method

  class << self
    attr_reader :builtin
  end

  def self.__initialize_pycall__
    initialized = (0 != LibPython.Py_IsInitialized())
    return if initialized

    LibPython.Py_InitializeEx(0)

    FFI::MemoryPointer.new(:pointer, 1) do |argv|
      argv.write_pointer(FFI::MemoryPointer.from_string(''))
      LibPython.PySys_SetArgvEx(0, argv, 0)
    end

    @builtin = LibPython.PyImport_ImportModule(PYTHON_VERSION < '3.0.0' ? '__builtin__' : 'builtins').to_ruby
  end

  __initialize_pycall__
end

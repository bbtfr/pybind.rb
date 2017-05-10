module PyBind
  module Utils
    BUILTIN_FUNCS = %w[
      getattr hasattr setattr delattr
      id type dir len iter next
    ]

    BUILTIN_FUNCS.each do |func|
      define_method(func) do |*args|
        PyBind.builtin.get_attribute(func).call(*args)
      end
    end

    MODULE_SHORTCUTS = %w[
      types traceback
    ]

    MODULE_SHORTCUTS.each do |mod|
      define_method(mod) do |*args|
        PyBind.import(mod)
      end
    end

    def None
      LibPython.Py_None
    end

    def True
      LibPython.Py_True
    end

    def False
      LibPython.Py_False
    end

    def eval(str)
      dict = main_dict
      eval_func = PyBind.builtin.get_attribute('eval')
      eval_func.call(str, dict, dict)
    end

    def execfile(filename)
      dict = main_dict
      if PyBind.builtin.has_attribute?('execfile')
        execfile_func = PyBind.builtin.get_attribute('execfile')
        execfile_func.call(filename, dict, dict)
      else
        open_func = PyBind.builtin.get_attribute('open')
        exec_func = PyBind.builtin.get_attribute('exec')
        content = open_func.call(filename).get_attribute('read').call()
        exec_func.(content, dict, dict)
      end
    end

    def callable?(pyobj)
      pystruct = pyobj.to_python_struct
      LibPython.PyCallable_Check(pystruct) == 1
    end

    def incref(pyobj)
      pystruct = pyobj.to_python_struct
      LibPython.Py_IncRef(pystruct)
      pyobj
    end

    def decref(pyobj)
      pystruct = pyobj.to_python_struct
      LibPython.Py_DecRef(pystruct)
      pystruct.send :pointer=, FFI::Pointer::NULL
      pyobj
    end

    def dict(args)
      PyDict.new(args)
    end

    def set(args)
      PySet.new(args)
    end

    def slice(*args)
      PySlice.new(*args)
    end

    def tuple(*args)
      PyTuple.new(args)
    end

    private

    def main_dict
      LibPython.PyModule_GetDict(PyBind.import("__main__").to_python_struct).to_ruby
    end
  end

  extend Utils
end

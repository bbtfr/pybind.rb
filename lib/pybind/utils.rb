module PyBind
  module Utils
    BUILTIN_FUNCS = %w[
      getattr hasattr setattr delattr
      id type dir len iter next
      isinstance issubclass str repr int
    ]

    BUILTIN_FUNCS.each do |func|
      define_method(func) do |*args|
        PyBind.builtin.get_attr(func).call(*args)
      end
    end

    MODULE_SHORTCUTS = %w[
      sys os types traceback
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
      eval_func = PyBind.builtin.get_attr('eval')
      eval_func.call(str, dict, dict)
    end

    def execfile(filename)
      dict = main_dict
      if PyBind.builtin.has_attr?('execfile')
        execfile_func = PyBind.builtin.get_attr('execfile')
        execfile_func.call(filename, dict, dict)
      else
        open_func = PyBind.builtin.get_attr('open')
        exec_func = PyBind.builtin.get_attr('exec')
        content = open_func.call(filename).get_attr('read').call()
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

    def parse_traceback(traceback)
      format_tb_func = PyBind.traceback.get_attr('format_tb')
      format_tb_func.call(traceback).to_a
    end

    private

    def main_dict
      LibPython.PyModule_GetDict(PyBind.import("__main__").to_python_struct).to_ruby
    end
  end

  extend Utils
end

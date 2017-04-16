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
        PyBind.import_module(mod)
      end
    end

    def None
      LibPython.Py_None
    end

    def main_dict
      LibPython.PyModule_GetDict(PyBind.import_module("__main__").__pyref__).to_ruby
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
      pyref = TypeCast.to_pyref(pyobj)
      LibPython.PyCallable_Check(pyref) == 1
    end

    def incref(pyobj)
      pyref = TypeCast.to_pyref(pyobj)
      LibPython.Py_IncRef(pyref)
      pyobj
    end

    def decref(pyobj)
      pyref = TypeCast.to_pyref(pyobj)
      LibPython.Py_DecRef(pyref)
      pyref.send :pointer=, FFI::Pointer::NULL
      pyobj
    end

    def parse_traceback(traceback)
      format_tb_func = PyBind.traceback.get_attr('format_tb')
      format_tb_func.call(traceback).to_a
    end
  end

  extend Utils
end

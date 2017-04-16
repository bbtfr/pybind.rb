module PyBind
  module Utils
    BUILTIN_FUNCS = %w[
      getattr hasattr setattr delattr
      id type dir len iter next
      isinstance issubclass str repr int
    ]

    BUILTIN_FUNCS.each do |func|
      define_method(func) do |*args|
        PyBind.builtin.get_attr(func).(*args)
      end
    end

    MODULE_SHORTCUTS = %w[
      sys os
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
      PyBind.builtin.eval.(str, dict, dict)
    end

    def execfile(filename)
      dict = main_dict
      PyBind.builtin.execfile.(filename, dict, dict)
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
  end

  extend Utils
end

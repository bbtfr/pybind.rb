require 'ffi'

module PyBind
  module LibPython
    extend FFI::Library

    def self.find_libpython(python = nil)
      python ||= ENV['PYTHON'] || 'python'
      python_config = investigate_python_config(python)

      version = python_config[:VERSION]
      libprefix = FFI::Platform::LIBPREFIX
      libs = []
      %i(INSTSONAME LDLIBRARY).each do |key|
        lib = python_config[key]
        libs << lib << File.basename(lib) if lib
      end
      if (lib = python_config[:LIBRARY])
        libs << File.basename(lib, File.extname(lib))
      end
      libs << "#{libprefix}python#{version}" << "#{libprefix}python"
      libs.uniq!

      executable = python_config[:EXECUTABLE]
      libpaths = [ python_config[:LIBDIR] ]
      if FFI::Platform.windows?
        libpaths << File.dirname(executable)
      else
        libpaths << File.expand_path('../../lib', executable)
      end
      libpaths << python_config[:PYTHONFRAMEWORKPREFIX] if FFI::Platform.mac?
      exec_prefix = python_config[:EXECPREFIX]
      libpaths << exec_prefix << File.join(exec_prefix, 'lib')
      libpaths.compact!

      unless ENV['PYTHONHOME']
        # PYTHONHOME tells python where to look for both pure python and binary modules.
        # When it is set, it replaces both `prefix` and `exec_prefix`
        # and we thus need to set it to both in case they differ.
        # This is also what the documentation recommends.
        # However, they are documented to always be the same on Windows,
        # where it causes problems if we try to include both.
        if FFI::Platform.windows?
          ENV['PYTHONHOME'] = exec_prefix
        else
          ENV['PYTHONHOME'] = [python_config[:PREFIX], exec_prefix].join(':')
        end

        # Unfortunately, setting PYTHONHOME screws up Canopy's Python distribution?
        unless system(python, '-c', 'import site', out: File::NULL, err: File::NULL)
          ENV['PYTHONHOME'] = nil
        end
      end

      # Try LIBPYTHON environment variable first.
      if ENV['LIBPYTHON']
        if File.file?(ENV['LIBPYTHON'])
          begin
            libs = ffi_lib(ENV['LIBPYTHON'])
            return libs.first
          rescue LoadError
          end
        end
        $stderr.puts '[WARN] Ignore the wrong libpython location specified in LIBPYTHON environment variable.'
      end

      # Find libpython (we hope):
      libsuffix = FFI::Platform::LIBSUFFIX
      multiarch = python_config[:MULTIARCH] || python_config[:IMPLEMENTATIONMULTIARCH]
      dir_sep = File::ALT_SEPARATOR || File::SEPARATOR
      libs.each do |lib|
        libpaths.each do |libpath|
          # NOTE: File.join doesn't use File::ALT_SEPARATOR
          libpath_libs = [ [libpath, lib].join(dir_sep) ]
          libpath_libs << [libpath, multiarch, lib].join(dir_sep) if multiarch
          libpath_libs.each do |libpath_lib|
            [
              libpath_lib,
              "#{libpath_lib}.#{libsuffix}"
            ].each do |fullname|
              next unless File.file?(fullname)
              begin
                libs = ffi_lib(fullname)
                return libs.first
              rescue LoadError
                # skip load error
              end
            end
          end
        end
      end
    end

    def self.investigate_python_config(python)
      python_env = { 'PYTHONIOENCODING' => 'UTF-8' }
      IO.popen(python_env, [python, python_investigator_py], 'r') do |io|
        {}.tap do |config|
          io.each_line do |line|
            key, value = line.chomp.split(': ', 2)
            config[key.to_sym] = value if value != 'None'
          end
        end
      end
    end

    def self.python_investigator_py
      File.expand_path('../python/investigator.py', __FILE__)
    end

    ffi_lib_flags :lazy, :global
    libpython = find_libpython ENV['PYTHON']

    # --- global variables ---

    attach_variable :_Py_NoneStruct, PyObjectStruct

    def self.Py_None
      _Py_NoneStruct
    end

    attach_variable :PyType_Type, PyObjectStruct

    if libpython.find_variable('PyInt_Type')
      has_PyInt_Type = true
      attach_variable :PyInt_Type, PyObjectStruct
    else
      has_PyInt_Type = false
      attach_variable :PyInt_Type, :PyLong_Type, PyObjectStruct
    end

    attach_variable :PyLong_Type, PyObjectStruct
    attach_variable :PyBool_Type, PyObjectStruct
    attach_variable :PyFloat_Type, PyObjectStruct
    attach_variable :PyComplex_Type, PyObjectStruct
    attach_variable :PyUnicode_Type, PyObjectStruct

    if libpython.find_symbol('PyString_FromStringAndSize')
      string_as_bytes = false
      attach_variable :PyString_Type, PyObjectStruct
    else
      string_as_bytes = true
      attach_variable :PyString_Type, :PyBytes_Type, PyObjectStruct
    end

    attach_variable :PyTuple_Type, PyObjectStruct
    attach_variable :PySlice_Type, PyObjectStruct
    attach_variable :PyList_Type, PyObjectStruct
    attach_variable :PyDict_Type, PyObjectStruct
    attach_variable :PySet_Type, PyObjectStruct

    attach_variable :PyFunction_Type, PyObjectStruct
    attach_variable :PyMethod_Type, PyObjectStruct

    # --- functions ---

    attach_function :Py_GetVersion, [], :string
    attach_function :Py_InitializeEx, [:int], :void
    attach_function :Py_IsInitialized, [], :int
    attach_function :PySys_SetArgvEx, [:int, :pointer, :int], :void

    # Reference count

    attach_function :Py_IncRef, [PyObjectStruct.by_ref], :void
    attach_function :Py_DecRef, [PyObjectStruct.by_ref], :void

    # Object

    attach_function :PyObject_RichCompare, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, :int], PyObjectStruct.by_ref
    attach_function :PyObject_RichCompareBool, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, :int], :int
    attach_function :PyObject_GetAttrString, [PyObjectStruct.by_ref, :string], PyObjectStruct.by_ref
    attach_function :PyObject_SetAttrString, [PyObjectStruct.by_ref, :string, PyObjectStruct.by_ref], :int
    attach_function :PyObject_HasAttrString, [PyObjectStruct.by_ref, :string], :int
    attach_function :PyObject_GetItem, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyObject_SetItem, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PyObject_DelItem, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PyObject_Call, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyObject_IsInstance, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PyObject_IsSubclass, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PyObject_Dir, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyObject_Repr, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyObject_Str, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyObject_Type, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyCallable_Check, [PyObjectStruct.by_ref], :int

    # PyObject_Compare only avaliable in Python 3.x
    if libpython.find_symbol('PyObject_DelAttrString')
      attach_function :PyObject_DelAttrString, [PyObjectStruct.by_ref, :string], :int
    end

    # PyObject_Compare only avaliable in Python 2.x
    if libpython.find_symbol('PyObject_Compare')
      attach_function :PyObject_Compare, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    end

    # Bool

    attach_function :PyBool_FromLong, [:long], PyObjectStruct.by_ref
    attach_variable :_Py_TrueStruct, PyObjectStruct
    attach_variable :_Py_ZeroStruct, PyObjectStruct

    def self.Py_True
      _Py_TrueStruct
    end

    def self.Py_False
      _Py_ZeroStruct
    end

    # Integer

    if has_PyInt_Type
      attach_function :PyInt_AsSsize_t, [PyObjectStruct.by_ref], :ssize_t
    else
      attach_function :PyInt_AsSsize_t, :PyLong_AsSsize_t, [PyObjectStruct.by_ref], :ssize_t
    end

    if has_PyInt_Type
      attach_function :PyInt_FromSsize_t, [:ssize_t], PyObjectStruct.by_ref
    else
      attach_function :PyInt_FromSsize_t, :PyLong_FromSsize_t, [:ssize_t], PyObjectStruct.by_ref
    end

    # Float

    attach_function :PyFloat_FromDouble, [:double], PyObjectStruct.by_ref
    attach_function :PyFloat_AsDouble, [PyObjectStruct.by_ref], :double

    # Complex

    attach_function :PyComplex_RealAsDouble, [PyObjectStruct.by_ref], :double
    attach_function :PyComplex_ImagAsDouble, [PyObjectStruct.by_ref], :double

    # String

    if string_as_bytes
      attach_function :PyString_FromStringAndSize, :PyBytes_FromStringAndSize, [:string, :ssize_t], PyObjectStruct.by_ref
    else
      attach_function :PyString_FromStringAndSize, [:string, :ssize_t], PyObjectStruct.by_ref
    end

    # PyString_AsStringAndSize :: (PyPtr, char**, int*) -> int
    if string_as_bytes
      attach_function :PyString_AsStringAndSize, :PyBytes_AsStringAndSize, [PyObjectStruct.by_ref, :pointer, :pointer], :int
    else
      attach_function :PyString_AsStringAndSize, [PyObjectStruct.by_ref, :pointer, :pointer], :int
    end

    # Unicode

    # PyUnicode_DecodeUTF8
    case
    when libpython.find_symbol('PyUnicode_DecodeUTF8')
      attach_function :PyUnicode_DecodeUTF8, [:string, :ssize_t, :string], PyObjectStruct.by_ref
    when libpython.find_symbol('PyUnicodeUCS4_DecodeUTF8')
      attach_function :PyUnicode_DecodeUTF8, :PyUnicodeUCS4_DecodeUTF8, [:string, :ssize_t, :string], PyObjectStruct.by_ref
    when libpython.find_symbol('PyUnicodeUCS2_DecodeUTF8')
      attach_function :PyUnicode_DecodeUTF8, :PyUnicodeUCS2_DecodeUTF8, [:string, :ssize_t, :string], PyObjectStruct.by_ref
    end

    # PyUnicode_AsUTF8String
    case
    when libpython.find_symbol('PyUnicode_AsUTF8String')
      attach_function :PyUnicode_AsUTF8String, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    when libpython.find_symbol('PyUnicodeUCS4_AsUTF8String')
      attach_function :PyUnicode_AsUTF8String, :PyUnicodeUCS4_AsUTF8String, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    when libpython.find_symbol('PyUnicodeUCS2_AsUTF8String')
      attach_function :PyUnicode_AsUTF8String, :PyUnicodeUCS2_AsUTF8String, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    end

    # Tuple

    attach_function :PyTuple_New, [:ssize_t], PyObjectStruct.by_ref
    attach_function :PyTuple_GetItem, [PyObjectStruct.by_ref, :ssize_t], PyObjectStruct.by_ref
    attach_function :PyTuple_SetItem, [PyObjectStruct.by_ref, :ssize_t, PyObjectStruct.by_ref], :int
    attach_function :PyTuple_Size, [PyObjectStruct.by_ref], :ssize_t

    # Slice

    attach_function :PySlice_New, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref

    # List

    attach_function :PyList_New, [:ssize_t], PyObjectStruct.by_ref
    attach_function :PyList_Size, [PyObjectStruct.by_ref], :ssize_t
    attach_function :PyList_GetItem, [PyObjectStruct.by_ref, :ssize_t], PyObjectStruct.by_ref
    attach_function :PyList_SetItem, [PyObjectStruct.by_ref, :ssize_t, PyObjectStruct.by_ref], :int
    attach_function :PyList_Append, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int

    # Sequence

    attach_function :PySequence_Size, [PyObjectStruct.by_ref], :ssize_t
    attach_function :PySequence_GetItem, [PyObjectStruct.by_ref, :ssize_t], PyObjectStruct.by_ref
    attach_function :PySequence_Contains, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int

    # Dict

    attach_function :PyDict_New, [], PyObjectStruct.by_ref
    attach_function :PyDict_GetItem, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyDict_GetItemString, [PyObjectStruct.by_ref, :string], PyObjectStruct.by_ref
    attach_function :PyDict_SetItem, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PyDict_SetItemString, [PyObjectStruct.by_ref, :string, PyObjectStruct.by_ref], :int
    attach_function :PyDict_DelItem, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PyDict_DelItem, [PyObjectStruct.by_ref, :string], :int
    attach_function :PyDict_Size, [PyObjectStruct.by_ref], :ssize_t
    attach_function :PyDict_Keys, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyDict_Values, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyDict_Items, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyDict_Contains, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int

    # Set

    attach_function :PySet_Size, [PyObjectStruct.by_ref], :ssize_t
    attach_function :PySet_Contains, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PySet_Add, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int
    attach_function :PySet_Discard, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], :int

    # Module

    attach_function :PyModule_GetDict, [PyObjectStruct.by_ref], PyObjectStruct.by_ref

    # Import

    attach_function :PyImport_ImportModule, [:string], PyObjectStruct.by_ref

    # Operators

    attach_function :PyNumber_Add, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Subtract, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Multiply, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_TrueDivide, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Remainder, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Power, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Lshift, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Rshift, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_And, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Xor, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Or, [PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Positive, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Negative, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyNumber_Invert, [PyObjectStruct.by_ref], PyObjectStruct.by_ref
    attach_function :PyObject_Not, [PyObjectStruct.by_ref], :int

    # Compiler

    attach_function :Py_CompileString, [:string, :string, :int], PyObjectStruct.by_ref
    attach_function :PyEval_EvalCode, [PyObjectStruct.by_ref, PyObjectStruct.by_ref, PyObjectStruct.by_ref], PyObjectStruct.by_ref

    # Error

    attach_function :PyErr_Clear, [], :void
    attach_function :PyErr_Print, [], :void
    attach_function :PyErr_Occurred, [], PyObjectStruct.by_ref
    attach_function :PyErr_Fetch, [:pointer, :pointer, :pointer], :void
    attach_function :PyErr_NormalizeException, [:pointer, :pointer, :pointer], :void

    public_class_method
  end

  PYTHON_DESCRIPTION = LibPython.Py_GetVersion().freeze
  PYTHON_VERSION = PYTHON_DESCRIPTION.split(' ', 2)[0].freeze
end

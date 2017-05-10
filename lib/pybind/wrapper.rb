require 'pybind/wrapper/attr_accessor'
require 'pybind/wrapper/rich_comparer'
require 'pybind/wrapper/operator'

module PyBind
  module PyObjectClassMethods
    def bind_pytype(pytype, &block)
      raise ArgumentError, "#{self} is already bound with #{@pystruct}" if @pystruct
      define_singleton_method :from_python, &block if block
      @pystruct = pytype.to_python_struct
    end

    def python_instance?(pyobj)
      return false unless @pystruct
      pystruct = pyobj.to_python_struct
      value = LibPython.PyObject_IsInstance(pystruct, @pystruct)
      raise PyError.fetch if value == -1
      value == 1
    end

    def python_subclass?(pyobj)
      return false unless @pystruct
      pystruct = pyobj.to_python_struct
      value = LibPython.PyObject_IsSubclass(pystruct, @pystruct)
      raise PyError.fetch if value == -1
      value == 1
    end

    def from_python(pystruct)
      new(pystruct)
    end

    def to_python_struct
      @pystruct
    end
    alias_method :python_type, :to_python_struct
    alias_method :to_python, :to_python_struct
  end

  module PyClassWrapper
    def self.included(mod)
      mod.extend(PyObjectClassMethods)
      Types.register_type(mod)
    end
  end

  module PyObjectWrapper
    include AttrAccessor
    include RichComparer
    include Operator

    def initialize(pystruct)
      raise TypeError, "the argument must be a PyObjectStruct" unless pystruct.kind_of? PyObjectStruct
      @pystruct = pystruct
    end

    def call(*args, **kwargs)
      args = PyTuple[*args]
      kwargs = kwargs.empty? ? PyObject.null : PyDict.new(kwargs)
      res = LibPython.PyObject_Call(@pystruct, args.to_python_struct, kwargs.to_python_struct)
      raise PyError.fetch unless LibPython.PyErr_Occurred().null?
      res.to_ruby
    end

    def to_s
      str = LibPython.PyObject_Str(@pystruct)
      return str.to_ruby unless str.null?
      super
    end

    def inspect
      str = LibPython.PyObject_Repr(@pystruct)
      return "#<#{self.class}(#{str.to_ruby})>" unless str.null?
      super
    end

    extend Forwardable
    def_delegators :@pystruct, :null?, :none?

    def python_type
      LibPython.PyObject_Type(@pystruct).to_ruby
    end

    def to_python_struct
      @pystruct
    end
    alias_method :to_python, :to_python_struct

    def self.included(mod)
      mod.extend(PyObjectClassMethods)
      Types.register_type(mod)
    end

    private

    def method_missing(name, *args, **kwargs)
      attr_name = name.to_s
      is_setter = attr_name.end_with?("=")
      attr_name = attr_name.chomp('=') if is_setter

      if has_attr?(attr_name)
        if is_setter
          set_attr(attr_name, *args)
        else
          autocall_method_missing(get_attr(attr_name), *args, **kwargs)
        end
      else
        super
      end
    end

    def autocall_method_missing(value, *args, **kwargs)
      value
    end
  end
end

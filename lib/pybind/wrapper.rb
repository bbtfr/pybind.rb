require 'pybind/wrapper/attr_accessor'
require 'pybind/wrapper/rich_comparer'
require 'pybind/wrapper/operator'

module PyBind
  module PyObjectWrapper
    include AttrAccessor
    include RichComparer
    include Operator

    attr_reader :__pyref__

    def initialize(pyref)
      raise TypeError, "the argument must be a PyObjectRef" unless pyref.kind_of? PyObjectRef
      @__pyref__ = pyref
    end

    def type
      LibPython.PyObject_Type(__pyref__).to_ruby
    end

    def call(*args, **kwargs)
      args = PyTuple[*args]
      kwargs = kwargs.empty? ? PyObject.null : PyDict.new(kwargs)
      res = LibPython.PyObject_Call(__pyref__, args.__pyref__, kwargs.__pyref__)
      raise PyError.fetch unless LibPython.PyErr_Occurred().null?
      res.to_ruby
    end

    def to_s
      str = LibPython.PyObject_Str(__pyref__)
      return str.to_ruby unless str.null?
      str = LibPython.PyObject_Repr(__pyref__)
      return str.to_ruby unless str.null?
      super
    end

    def method_missing(name, *args, **kwargs)
      if has_attr?(name)
        get_attr(name)
      else
        super
      end
    end

    module ClassMethods
      attr_reader :__pyref__

      def pybind_type(pytype)
        raise TypeError, "#{self} is already bound with #{__pyref__}" if __pyref__
        @__pyref__ = pytype
        Types.register_type self
      end

      def is_instance?(pyobj)
        raise TypeError, "#{self} is not a python type" unless __pyref__
        pyref = TypeCast.from_ruby(pyobj)
        LibPython.PyObject_IsInstance(pyref, __pyref__) == 1
      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
    end
  end
end

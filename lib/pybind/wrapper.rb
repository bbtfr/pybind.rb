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

    def __pytype__
      LibPython.PyObject_Type(__pyref__).to_ruby
    end

    extend Forwardable
    def_delegators :__pyref__, :null?, :none?

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
      attr_reader :__rbtypes__

      def bind_pytype(pytype, &block)
        raise ArgumentError, "#{self} is already bound with #{__pyref__}" if __pyref__
        define_singleton_method :to_ruby, &block if block
        @__pyref__ = pytype
      end

      def pyinstance?(pyobj)
        return false unless __pyref__
        pyref = TypeCast.to_pyref(pyobj)
        value = LibPython.PyObject_IsInstance(pyref, __pyref__)
        raise PyError.fetch if value == -1
        value == 1
      end

      def pysubclass?(pyobj)
        return false unless __pyref__
        pyref = TypeCast.to_pyref(pyobj)
        value = LibPython.PyObject_IsSubclass(pyref, __pyref__)
        raise PyError.fetch if value == -1
        value == 1
      end

      def to_ruby(pyref)
        new(pyref)
      end

      def bind_rbtype(*rbtypes, &block)
        raise ArgumentError, "#{self} is already bound with #{__rbtypes__}" if __rbtypes__
        define_singleton_method :from_ruby, &block if block
        @__rbtypes__ = rbtypes
      end

      def rbinstance?(rbobj)
        return false unless __rbtypes__
        __rbtypes__.any? { |rbtype| rbtype === rbobj }
      end
    end

    def self.included(mod)
      mod.extend(ClassMethods)
      Types.register_type(mod)
    end
  end
end

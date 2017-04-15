module PyBind
  module AttrAccessor
    def get_attr(name, default = nil)
      value = LibPython.PyObject_GetAttrString(__pyref__, name.to_s)
      if value.null?
        raise PyError.fetch unless default
        return default
      end
      value.to_ruby
    end

    def set_attr(name, value)
      value = TypeCast.from_ruby(value)
      raise PyError.fetch if LibPython.PyObject_SetAttrString(__pyref__, name.to_s, value) == -1
      self
    end

    def has_attr?(name)
      LibPython.PyObject_HasAttrString(__pyref__, name.to_s) == 1
    end

    def [](*indices)
      if indices.length == 1
        indices = indices[0]
      else
        indices = PyCall.tuple(*indices)
      end
      pykey = TypeCast.from_ruby(indices)
      value = LibPython.PyObject_GetItem(__pyref__, pykey)
      raise PyError.fetch if value.null?
      value.to_ruby
    end

    def []=(*indices_and_value)
      value = indices_and_value.pop
      indices = indices_and_value
      if indices.length == 1
        indices = indices[0]
      else
        indices = PyCall.tuple(*indices)
      end
      pykey = TypeCast.from_ruby(indices)
      value = TypeCast.from_ruby(value)
      raise PyError.fetch if LibPython.PyObject_SetItem(__pyref__, pykey, value) == -1
      self
    end

  end
end

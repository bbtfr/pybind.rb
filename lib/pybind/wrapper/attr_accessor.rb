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
      res = LibPython.PyObject_SetAttrString(__pyref__, name.to_s, value)
      raise PyError.fetch if res == -1
      self
    end

    def has_attr?(name)
      LibPython.PyObject_HasAttrString(__pyref__, name.to_s) == 1
    end
  end
end

module PyBind
  module AttrAccessor
    def get_attr(name, default = nil)
      value = LibPython.PyObject_GetAttrString(__pyref__, name.to_s)
      if value.null?
        return default if default
        raise PyError.fetch
      end
      value.to_ruby
    end

    def set_attr(name, value)
      value = TypeCast.from_ruby(value)
      return self unless LibPython.PyObject_SetAttrString(__pyref__, name.to_s, value) == -1
      raise PyError.fetch
    end

    def has_attr?(name)
      LibPython.PyObject_HasAttrString(__pyref__, name.to_s) == 1
    end
  end
end

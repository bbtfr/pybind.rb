module PyBind
  module AttrAccessor
    def get_attribute(name, default = nil)
      value = LibPython.PyObject_GetAttrString(@pystruct, name.to_s)
      if value.null?
        raise PyError.fetch unless default
        return default
      end
      value.to_ruby
    end

    def set_attribute(name, value)
      value = value.to_python
      ret = LibPython.PyObject_SetAttrString(@pystruct, name.to_s, value)
      raise PyError.fetch if ret == -1
      self
    end

    def remove_attribute(name)
      value = LibPython.PyObject_GetAttrString(@pystruct, name.to_s)
      raise PyError.fetch if value.null?
      ret = if LibPython.respond_to? :PyObject_DelAttrString
          LibPython.PyObject_DelAttrString(@pystruct, name.to_s)
        else
          LibPython.PyObject_SetAttrString(@pystruct, name.to_s, PyBind.None)
        end
      raise PyError.fetch if ret == -1
      value.to_ruby
    end

    def has_attribute?(name)
      LibPython.PyObject_HasAttrString(@pystruct, name.to_s) == 1
    end

    def [](*indices)
      key = TypeCast.to_python_arguments(indices)
      value = LibPython.PyObject_GetItem(@pystruct, key)
      raise PyError.fetch if value.null?
      value.to_ruby
    end

    def []=(*indices_and_value)
      value = indices_and_value.pop
      indices = indices_and_value
      key = TypeCast.to_python_arguments(indices)
      value = value.to_python
      ret = LibPython.PyObject_SetItem(@pystruct, pykey, value)
      raise PyError.fetch if ret == -1
      self
    end

  end
end

module PyBind
  module AttrAccessor
    def get_attr(name, default = nil)
      __pyref__.attr(name)
    rescue PyError => pyerr
      raise .fetch unless default
      default
    end

    def set_attr(name, value)
      value = TypeCast.from_ruby(value)
      ret = LibPython.PyObject_SetAttrString(__pyref__, name.to_s, value)
      raise PyError.fetch if ret == -1
      self
    end

    def del_attr(name)
      value = LibPython.PyObject_GetAttrString(__pyref__, name.to_s)
      raise PyError.fetch if value.null?
      ret = if LibPython.respond_to? :PyObject_DelAttrString
          LibPython.PyObject_DelAttrString(__pyref__, name.to_s)
        else
          LibPython.PyObject_SetAttrString(__pyref__, name.to_s, PyBind.None)
        end
      raise PyError.fetch if ret == -1
      value.to_ruby
    end

    def has_attr?(name)
      LibPython.PyObject_HasAttrString(__pyref__, name.to_s) == 1
    end

    def [](*indices)
      __pyref__.item(*indices)
    end

    def []=(*indices_and_value)
      value = indices_and_value.pop
      indices = indices_and_value
      key = TypeCast.to_indices_pyref(indices)
      value = TypeCast.from_ruby(value)
      ret = LibPython.PyObject_SetItem(__pyref__, pykey, value)
      raise PyError.fetch if ret == -1
      self
    end

  end
end

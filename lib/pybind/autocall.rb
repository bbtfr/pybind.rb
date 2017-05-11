module PyBind
  module PyObjectWrapper
    def autocall_method_missing(value, *args, **kwargs)
      if value.callable?
        value.call(*args, **kwargs)
      else
        value
      end
    end
  end
end

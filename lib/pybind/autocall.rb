module PyBind
  module PyObjectWrapper
    def autocall_method_missing(value, *args, **kwargs)
      if PyBind.callable? value
        value.call(*args, **kwargs)
      else
        value
      end
    end
  end
end

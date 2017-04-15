module PyBind
  module Import
    def pyimport(mod_name, as: mod_name)
      check_valid_module_variable_name(mod_name, as)

      mod = PyBind.import_module(mod_name)
      raise PyError.fetch unless mod

      define_singleton_method(as) { mod }
    end

    def check_valid_module_variable_name(mod_name, var_name)
      var_name = var_name.to_s if var_name.is_a? Symbol
      if var_name.include?('.')
        raise ArgumentError, "#{var_name.inspect} is not a valid module variable name, use pyimport #{mod_name.inspect}, as: <name>"
      end
    end
  end

  def self.import_module(name)
    name = name.to_s if name.is_a? Symbol
    raise TypeError, 'name must be a String' unless name.is_a? String
    value = LibPython.PyImport_ImportModule(name)
    raise PyError.fetch if value.null?
    value = value.to_ruby
    return value unless block_given?
    yield value
  end
end

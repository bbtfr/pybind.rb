module PyBind
  module Import
    def pyimport(mod_name, as: mod_name)
      if as.to_s.include?('.')
        raise ArgumentError, "#{as.inspect} is not a valid module variable name, use pyimport #{mod_name.inspect}, as: <name>"
      end

      mod = PyBind.import_module(mod_name)
      raise PyError.fetch unless mod

      define_singleton_method(as) { mod }
    end

    def pyfrom(mod_name, import: nil)
      raise ArgumentError, "missing identifiers to be imported" unless import

      mod = PyBind.import_module(mod_name)
      raise PyError.fetch unless mod

      case import
      when Hash
        import.each do |attr, as|
          val = mod.get_attr(attr)
          define_singleton_method(as) { val }
        end
      when Array
        import.each do |attr|
          val = mod.get_attr(attr)
          define_singleton_method(attr) { val }
        end
      when Symbol, String
        val = mod.get_attr(import)
        define_singleton_method(import) { val }
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

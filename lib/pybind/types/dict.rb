module PyBind
  class PyDict
    include Enumerable
    include PyObjectWrapper
    bind_pytype LibPython.PyDict_Type

    bind_rbtype Hash do |obj|
      PyDict.new(obj).__pyref__
    end

    def self.new(init = nil)
      case init
      when PyObjectStruct
        super
      when nil
        new(LibPython.PyDict_New())
      when Hash
        new.tap do |dict|
          init.each do |key, value|
            dict[key] = value
          end
        end
      else
        raise TypeError, "the argument must be a PyObjectStruct or a Hash"
      end
    end

    def [](key)
      case key
      when String, Symbol
        LibPython.PyDict_GetItemString(__pyref__, key.to_s).to_ruby
      else
        key = TypeCast.from_ruby(key)
        LibPython.PyDict_GetItem(__pyref__, key).to_ruby
      end
    end

    def []=(key, value)
      value = TypeCast.from_ruby(value)
      case key
      when String, Symbol
        LibPython.PyDict_SetItemString(__pyref__, key.to_s, value)
      else
        key = TypeCast.from_ruby(key)
        LibPython.PyDict_SetItem(__pyref__, key, value)
      end
      value
    end

    def delete(key)
      case key
      when String, Symbol
        value = LibPython.PyDict_GetItemString(__pyref__, key).to_ruby
        LibPython.PyDict_DelItemString(__pyref__, key.to_s)
      else
        key = TypeCast.from_ruby(key)
        value = LibPython.PyDict_GetItem(__pyref__, key).to_ruby
        LibPython.PyDict_DelItem(__pyref__, key)
      end
      value
    end

    def size
      LibPython.PyDict_Size(__pyref__)
    end

    def keys
      LibPython.PyDict_Keys(__pyref__).to_ruby
    end

    def values
      LibPython.PyDict_Values(__pyref__).to_ruby
    end

    def has_key?(key)
      key = TypeCast.from_ruby(key)
      value = LibPython.PyDict_Contains(__pyref__, key)
      raise PyError.fetch if value == -1
      value == 1
    end

    def to_a
      LibPython.PyDict_Items(__pyref__).to_ruby
    end

    def to_hash
      Hash[to_a]
    end

    def each
      return enum_for unless block_given?
      keys.each do |key|
        yield key, self[key]
      end
      self
    end
  end
end

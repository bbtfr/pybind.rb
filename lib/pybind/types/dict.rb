module PyBind
  class PyDict
    include Enumerable
    include PyObjectWrapper
    bind_pytype LibPython.PyDict_Type

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
        LibPython.PyDict_GetItemString(@pystruct, key.to_s).to_ruby
      else
        key = key.to_python
        LibPython.PyDict_GetItem(@pystruct, key).to_ruby
      end
    end

    def []=(key, value)
      value = value.to_python
      case key
      when String, Symbol
        LibPython.PyDict_SetItemString(@pystruct, key.to_s, value)
      else
        key = key.to_python
        LibPython.PyDict_SetItem(@pystruct, key, value)
      end
      value
    end

    def delete(key)
      case key
      when String, Symbol
        value = LibPython.PyDict_GetItemString(@pystruct, key).to_ruby
        LibPython.PyDict_DelItemString(@pystruct, key.to_s)
      else
        key = key.to_python
        value = LibPython.PyDict_GetItem(@pystruct, key).to_ruby
        LibPython.PyDict_DelItem(@pystruct, key)
      end
      value
    end

    def size
      LibPython.PyDict_Size(@pystruct)
    end

    def keys
      LibPython.PyDict_Keys(@pystruct).to_ruby
    end

    def values
      LibPython.PyDict_Values(@pystruct).to_ruby
    end

    def has_key?(key)
      key = key.to_python
      value = LibPython.PyDict_Contains(@pystruct, key)
      raise PyError.fetch if value == -1
      value == 1
    end

    def to_a
      LibPython.PyDict_Items(@pystruct).to_ruby
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

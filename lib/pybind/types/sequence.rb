module PyBind
  module PySequence
    include Enumerable

    def include?(value)
      value = TypeCast.from_ruby(value)
      value = LibPython.PySequence_Contains(__pyref__, value)
      raise PyError.fetch if value == -1
      value == 1
    end

    def each
      return enum_for unless block_given?
      size.times do |i|
        yield self[i]
      end
      self
    end

    def to_a
      each.to_a
    end

    alias_method :to_ary, :to_a
  end
end

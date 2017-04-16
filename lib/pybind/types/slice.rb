module PyBind
  class PySlice
    include PyObjectWrapper
    bind_pytype LibPython.PySlice_Type

    def self.new(start, stop = nil, step = nil)
      if stop.nil? && step.nil?
        start, stop = nil, start
        return super(stop) if stop.kind_of?(PyObjectRef)
      end
      start = start ? TypeCast.from_ruby(start) : PyObjectRef.null
      stop = stop ? TypeCast.from_ruby(stop) : PyObjectRef.null
      step = step ? TypeCast.from_ruby(step) : PyObjectRef.null
      pyobj = LibPython.PySlice_New(start, stop, step)
      raise PyError.fetch if pyobj.null?
      pyobj.to_ruby
    end
  end
end

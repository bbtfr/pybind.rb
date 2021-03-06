module PyBind
  class PySlice
    include PyObjectWrapper
    pybind_type LibPython.PySlice_Type

    def self.new(start, stop = nil, step = nil)
      if stop.nil? && step.nil?
        start, stop = nil, start
        return super(stop) if stop.kind_of?(PyObjectStruct)
      end
      start = start ? start.to_python : PyObjectStruct.null
      stop = stop ? stop.to_python : PyObjectStruct.null
      step = step ? step.to_python : PyObjectStruct.null
      pyobj = LibPython.PySlice_New(start, stop, step)
      raise PyError.fetch if pyobj.null?
      pyobj.to_ruby
    end
  end
end

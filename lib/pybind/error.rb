module PyBind
  class PyError < StandardError
    def self.fetch
      ptrs = FFI::MemoryPointer.new(:pointer, 3)
      ptype      = ptrs + 0 * ptrs.type_size
      pvalue     = ptrs + 1 * ptrs.type_size
      ptraceback = ptrs + 2 * ptrs.type_size
      LibPython.PyErr_Fetch(ptype, pvalue, ptraceback)
      LibPython.PyErr_NormalizeException(ptype, pvalue, ptraceback)
      type = TypeCast.from_python(PyObjectStruct.new(ptype.read(:pointer)))
      value = TypeCast.from_python(PyObjectStruct.new(pvalue.read(:pointer)))
      traceback = TypeCast.from_python(PyObjectStruct.new(ptraceback.read(:pointer)))
      new(type, value, traceback)
    end

    def initialize(type, value, traceback)
      @type = type
      @value = value
      @traceback = traceback
      super("#{type}: #{value}")
    end

    attr_reader :type, :value, :traceback

    def message
      baseline = super
      lines = [baseline] + PyBind.parse_traceback(traceback)
      lines.join("\n")
    rescue
      baseline
    end
  end

  def self.parse_traceback(traceback)
    format_tb_func = PyBind.traceback.get_attribute('format_tb')
    format_tb_func.call(traceback).to_a
  end
end

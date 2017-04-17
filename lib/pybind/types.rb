module PyBind
  module Types
    class << self
      attr_reader :pytypes
    end

    @pytypes ||= []
    def self.register_type(pytype)
      @pytypes.unshift(pytype)
    end
  end
end

require 'pybind/core_ext/basic'
require 'pybind/types/basic'
require 'pybind/types/object'
require 'pybind/types/tuple'
require 'pybind/types/slice'
require 'pybind/types/list'
require 'pybind/types/dict'
require 'pybind/types/set'

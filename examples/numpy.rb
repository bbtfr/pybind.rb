require 'pry'

require 'pybind'
require 'pybind/autocall'
include PyBind::Import

np = PyBind.import('numpy')

binding.pry

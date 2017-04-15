require 'pybind'
include PyBind::Import

pyimport 'sys'

p sys.type.("abc")

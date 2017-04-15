require 'pybind'
include PyBind::Import

PyBind.builtin.print.([nil, 1,2,4])

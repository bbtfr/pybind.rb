require 'pybind'
include PyBind::Import

PyBind.builtin.print.([nil, 1,2,4])

PyBind::TypeCast.from_ruby([1]).to_ruby ^ 3

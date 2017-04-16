require 'pybind'
require 'pybind/autocall'

include PyBind::Import

# builtin function
pyimport 'numpy', as: :np
puts np.array([0])

# type
puts np.str('str')

# function
pyimport 'numpy.matlib', as: :ml
puts np.zeros([1])

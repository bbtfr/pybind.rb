require 'pybind'

# You can eval a string in Python with `PyBind.eval`,
# this is the easiest way to use PyBind.rb
# and this is equivalent to Python built-in `eval` function
PyBind.eval('print("Hello, world!")')

# Or exec a Python file
PyBind.execfile('examples/hello_world.py')

# You can find all Python built-in functions at PyBind.builtin
# Note that `PyBind.builtin.print` is a Python function object,
# like a `proc` in Ruby, you need to call it by adding a `.` or `.call`
PyBind.builtin.print.('hello, world!')

# PyBind

**PyBind.rb** is a lightweight Ruby - Python binding using [`ffi`](https://github.com/ffi/ffi), it aims to create a way to call exsisting Python functions in Ruby. With the power of PyBind.rb, you can use all data-science packages in Python, e.g.: `numpy`, `pandas`, `matplotlib`, and even `tensorflow`.

More use-cases can be found in `examples` folder.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pybind'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pybind

## Usage

Hello world with PyBind.rb

```ruby
# This program prints Hello, world!
require 'pybind'

# You can eval a string in Python with `PyBind.eval`,
# this is the easiest way to use PyBind.rb
# and this is equivalent to Python built-in `eval` function
PyBind.eval('print("Hello, world!")')

# Or exec a Python file
PyBind.execfile('examples/hello_world.py')

# You can find all Python built-in functions at `PyBind.builtin`
# Note that `PyBind.builtin.print` is a Python function object,
# like a `proc` in Ruby, you need to call it by adding a `.` or `.call`
# if you don't like it, see `pybind/autocall` secion below
PyBind.builtin.print.('hello, world!')
``` 

Import Python modules

```ruby
require 'pybind'
include PyBind::Import

pyimport 'os'
puts os.name
```

Customize convertor between Ruby & Python object

```ruby
require 'pybind'

Fraction = PyBind.import_module('fractions').Fraction

class PyFraction
  include PyBind::PyObjectWrapper
  pybind_type Fraction
end

f = Fraction.(1, 2)
f.kind_of? PyFraction # => true
f.numerator # => 1
f.denominator # => 2
```

Or you can map Python object to exsisting Ruby class

```ruby
require 'pybind'

class PyFraction
  include PyBind::PyObjectWrapper

  Fraction = PyBind.import_module('fractions').Fraction

  pybind_type Fraction do |pyref|
    # pyref is a PyObjectRef, which is a FFI::Struct
    # This block defines how Python object converts to Ruby object
    # By default, it's `new(pyref)`

    # For easily access the attributes, let's convert it to PyObject
    pyobj = PyBind::PyObject.new(pyref)
    Rational(pyobj.numerator, pyobj.denominator)
  end

  bind_rbtype Rational do |rbobj|
    # This block defines how Ruby object converts back to Python object
    Fraction.(rbobj.numerator, rbobj.denominator)
  end
end
```

If you don't like the dot everywhere before the function call (just like me), you can just `require 'pybind/autocall'`.
Note that this will heavily change the behavior of your code, but the life will be easier.

```ruby
require 'pybind'
require 'pybind/autocall'

# No dot anymore, if you need the function object, you need to call
# `PyBind.builtin.get_attr('print')`
PyBind.builtin.print('Hello, world!')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

**PyBind.rb** originally forked from [`pycall`](https://github.com/mrkn/pycall), special thanks goes to Kenta Murata ([`mrkn`](https://github.com/mrkn)) for his brilliant idea.

Bug reports and pull requests are welcome on GitHub at https://github.com/bbtfr/pybind.rb This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


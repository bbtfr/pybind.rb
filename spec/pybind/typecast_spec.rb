require 'spec_helper'

module PyBind
  ::RSpec.describe TypeCast do
    describe 'for object()' do
      specify { expect(PyBind.eval('object()')).to be_kind_of(PyObject) }
    end

    describe '.register_type' do
      include_context 'Save and restore original python type map'

      it 'adds type map between python type and ruby type' do
        klass = Class.new
        klass.include PyObjectWrapper
        expect {
          Types.register_type(klass)
        }.to change {
          Types.pytypes.size
        }.by(1)
      end
    end

    describe '.to_ruby' do
      include_context 'Save and restore original python type map'

      let(:fractions_module) do
        PyBind.import('fractions')
      end

      let(:fraction_class) do
        fractions_module.get_attr(:Fraction)
      end

      let(:fraction_value) do
        fraction_class.(355, 113)
      end

      context 'the given python type is not registered in type mapping' do
        it 'does not convert the given python object' do
          expect(TypeCast.from_python(fraction_value)).to be_kind_of(PyObjectWrapper)
        end
      end

      context 'the given python type is registered in type mapping' do
        before do
          fraction_value # NOTE: this line should be evaluated before the following line to prevent conversion

          klass = Class.new
          klass.include PyObjectWrapper
          klass.bind_pytype fraction_class do |pyref|
            pyobj = PyObject.new(pyref)
            Rational(pyobj.numerator, pyobj.denominator)
          end
        end

        after do
          Types.pytypes.delete_if do |type_pair|
            type_pair.python_type == fraction_class.to_python_struct
          end
        end

        it 'converts the given python object to the specific ruby object' do
          expect(TypeCast.from_python(fraction_value)).to eq(Rational(355, 113))
        end
      end
    end

    describe '.to_python' do
      def to_python(obj)
        obj.to_python
      end

      context 'for a PyObjectRef' do
        let(:pyobj) { PyBind.eval('object()') }
        subject { to_python(pyobj.to_python_struct) }
        it { is_expected.to equal(pyobj.to_python_struct) }
      end

      context 'for true' do
        subject { to_python(true) }
        it { is_expected.to be_kind_of(LibPython.PyBool_Type) }
        specify { expect(subject.to_ruby).to equal(true) }
      end

      context 'for false' do
        subject { to_python(false) }
        it { is_expected.to be_kind_of(LibPython.PyBool_Type) }
        specify { expect(subject.to_ruby).to equal(false) }
      end

      [-1, 0, 1].each do |int_value|
        context "for #{int_value}" do
          subject { to_python(int_value) }
          it { is_expected.to be_kind_of(LibPython.PyInt_Type) }
          specify { expect(subject.to_ruby).to eq(int_value) }
        end
      end

      [-Float::INFINITY, -1.0, 0.0, 1.0, Float::INFINITY, Float::NAN].each do |float_value|
        context "for #{float_value}" do
          subject { to_python(float_value) }
          it { is_expected.to be_kind_of(LibPython.PyFloat_Type) }
          if float_value.nan?
            specify { expect(subject.to_ruby).to be_nan }
          else
            specify { expect(subject.to_ruby).to eq(float_value) }
          end
        end
      end

      context 'for a Hash' do
        let(:hash) { { a: 1, b: 2, c: 3 } }
        subject { to_python(hash) }
        it { is_expected.to be_kind_of(LibPython.PyDict_Type) }
        specify { expect(TypeCast.from_python(subject)).to eq(hash) }
      end
    end
  end
end

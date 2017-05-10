require 'spec_helper'

module PyBind
  ::RSpec.describe PyObject do
    describe '.null' do
      specify do
        expect(PyObject.null).to be_null
      end
    end

    describe '#call' do
      it 'calls a PyObject as a function' do
        expect(PyBind.str(42)).to eq('42')
        expect(PyBind.int(10 * Math::PI)).to eq(31)
      end
    end

    describe '#python_type' do
      subject { PyObject.new(1.to_python) }

      it 'returns python type' do
        expect(subject.python_type.to_s).to eq "int"
      end
    end
  end
end

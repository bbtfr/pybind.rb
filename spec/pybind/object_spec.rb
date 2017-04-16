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

    describe '#__pytype__' do
      subject { PyObject.new(PyBind::TypeCast.from_ruby(1)) }

      it 'returns python type' do
        expect(subject.__pytype__.to_s).to eq "PyType(int)"
      end
    end
  end
end

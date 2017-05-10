require 'spec_helper'

module PyBind
  module RSpec
  end

  ::RSpec.describe PyObjectWrapper do
    describe '.pybind_type' do
      include_context 'Save and restore original python type map'

      context 'called with fractions.Fraction class' do
        it 'makes the class as a Fraction object wrapper' do
          fraction_class = PyBind.import('fractions').Fraction

          klass = Class.new
          klass.include PyObjectWrapper

          # before wrapping the class
          expect(fraction_class.(1, 2)).to be_kind_of(PyObjectWrapper)

          expect {
            klass.pybind_type fraction_class
          }.not_to raise_error

          # after wrapping the class
          expect(fraction_class.(1, 2)).to be_kind_of(klass)
        end
      end
    end

    describe '#rich_compare' do
      let(:fraction_class) { PyBind.import('fractions').Fraction }
      subject { fraction_class.(1, 2) }

      context 'when comparing with an Integer' do
        specify do
          expect { subject.__rich_compare__(42, :<) }.not_to raise_error
        end
      end

      context 'when comparing with an PyObject' do
        specify do
          expect { subject.__rich_compare__(fraction_class.(2, 3), :<) }.not_to raise_error
        end
      end
    end

    describe '#call' do
      context 'when less arguments' do
        specify do
          expect { PyBind.eval('len').() }.to raise_error(PyBind::PyError, /takes exactly one argument \(0 given\)/)
        end
      end
    end
  end
end

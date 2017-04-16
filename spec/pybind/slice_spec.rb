require 'spec_helper'

module PyBind
  ::RSpec.describe PySlice do
    let(:pylist) { PyList.new([1, 2, 3, 4, 5]) }

    context 'initialize with one nil' do
      subject { PySlice.new(nil) }
      specify do
        expect(subject.start).to eq(nil)
        expect(subject.stop).to eq(nil)
        expect(subject.step).to eq(nil)
      end
    end

    context 'start, stop, and step are all nil' do
      subject { PySlice.new(nil, nil, nil) }
      specify do
        expect(pylist[subject]).to eq([1, 2, 3, 4, 5])
      end
    end

    context 'initialize with one argument' do
      subject { PySlice.new(3) }
      specify do
        expect(subject.start).to eq(nil)
        expect(subject.stop).to eq(3)
        expect(subject.step).to eq(nil)

        expect(pylist[subject]).to eq([1, 2, 3])
      end
    end

    context 'initialize with two arguments' do
      subject { PySlice.new(1, 3) }
      specify do
        expect(subject.start).to eq(1)
        expect(subject.stop).to eq(3)
        expect(subject.step).to eq(nil)

        expect(pylist[subject]).to eq([2, 3])
      end
    end

    context 'initialize with three arguments' do
      subject { PySlice.new(1, 5, 2) }
      specify do
        expect(subject.start).to eq(1)
        expect(subject.stop).to eq(5)
        expect(subject.step).to eq(2)

        expect(pylist[subject]).to eq([2, 4])
      end
    end
  end
end

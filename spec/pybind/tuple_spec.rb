require 'spec_helper'

module PyBind
  ::RSpec.describe PyTuple do
    subject { PyTuple[1, 2, 3] }

    specify do
      expect(subject[0]).to eq(1)
      expect(subject[1]).to eq(2)
      expect(subject[2]).to eq(3)
    end

    describe '#size' do
      it 'returns its size' do
        expect(subject.size).to eq(3)
      end
    end
  end
end

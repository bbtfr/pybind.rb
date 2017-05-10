require 'spec_helper'

module PyBind
  RSpec.describe PyError do
    subject { PyError.new(type, value, traceback) }

    let(:pyerror) { begin PyBind.builtin.len.(); rescue => error; error end }
    let(:type) { pyerror.type }
    let(:value) { pyerror.value }
    let(:traceback) { pyerror.traceback }

    describe '#to_s' do
      shared_examples 'does not contain traceback' do
        it 'does not contain traceback' do
          expect(subject.to_s.lines.count).to eq(1)
        end
      end

      context 'when traceback is nil' do
        let(:traceback) { nil }
        include_examples 'does not contain traceback'
      end

      context 'when traceback is null' do
        let(:traceback) { FFI::Pointer::NULL }
        include_examples 'does not contain traceback'
      end
    end
  end
end

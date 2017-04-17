require 'spec_helper'

RSpec.describe PyBind do
  def py_eval(src)
    PyBind.eval(src)
  end

  def self.describe_eval(src, &block)
    describe ".eval(#{src.inspect})" do
      subject { py_eval(src) }
      module_eval &block
    end
  end

  describe 'PyBind.main_dict' do
    subject(:main_dict) { PyBind.main_dict }

    specify 'ob_refcnt >= 1' do
      expect(main_dict.to_python_struct[:ob_refcnt]).to be >= 1
    end
  end

  describe '.import_module' do
    context 'without block' do
      it 'returns an imported module' do
        begin
          mod = PyBind.import_module('__main__')
          expect(mod.python_type.to_s).to match(/module/)
        ensure
          PyBind.decref(mod.to_python_struct)
        end
      end
    end

    context 'with block' do
      it 'ensures to release python module object' do
        cnt = {}
        PyBind.import_module('__main__') { |outer_m|
          cnt[:before] = outer_m.to_python_struct[:ob_refcnt]
          PyBind.import_module('__main__') { |inner_m|
            cnt[:inner] = inner_m.to_python_struct[:ob_refcnt]
          }
          cnt[:after] = outer_m.to_python_struct[:ob_refcnt]
        }
        expect(cnt[:inner]).to eq(cnt[:before] + 1)
        expect(cnt[:after]).to eq(cnt[:before])
      end
    end
  end

  describe_eval('None') do
    it { is_expected.to equal(nil) }
  end

  describe_eval('True') do
    it { is_expected.to equal(true) }
  end

  describe_eval('False') do
    it { is_expected.to equal(false) }
  end

  describe_eval('1') do
    it { is_expected.to be_kind_of(Integer) }
    it { is_expected.to eq(1) }
  end

  describe_eval('1.0') do
    it { is_expected.to be_kind_of(Float) }
    it { is_expected.to eq(1.0) }
  end

  describe_eval('complex(1, 2)') do
    it { is_expected.to eq(1 + 2i) }
  end

  describe_eval('"python"') do
    it { is_expected.to eq("python") }
  end

  describe_eval('[1, 2, 3]') do
    it { is_expected.to eq([1, 2, 3]) }
  end

  describe_eval('(1, 2, 3)') do
    it { is_expected.to be_kind_of(PyBind::PyTuple) }
    it { is_expected.to eq(PyBind::PyTuple[1, 2, 3]) }
  end

  describe_eval('{ "a": 1, "b": 2 }') do
    it { is_expected.to be_kind_of(PyBind::PyDict) }
    specify do
      expect(subject['a']).to eq(1)
      expect(subject['b']).to eq(2)
      expect(subject['c']).to be_nil
    end
  end

  describe_eval('{1, 2, 3}') do
    it { is_expected.to be_kind_of(PyBind::PySet) }

    specify { expect(subject.size).to eq(3) }

    it { is_expected.to include(1, 2, 3) }
    it { is_expected.not_to include(0, 4) }
  end
end

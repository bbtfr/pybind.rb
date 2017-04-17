require "spec_helper"

RSpec.describe PyBind do
  it "has a version number" do
    expect(PyBind::VERSION).not_to be nil
  end

  describe 'PYTHON_VERSION' do
    it "has a Python's version number" do
      expect(PyBind::PYTHON_VERSION).to be_kind_of(String)
    end
  end

  describe '.None' do
    subject { PyBind.None }
    it { is_expected.to be_none }
    it { is_expected.not_to be_nil }
    it { is_expected.not_to eq(PyBind.eval('None')) }
    specify { expect(PyBind::PyObject.new(subject)).to eq(PyBind.eval('None')) }
  end

  describe '.callable?' do
    it 'detects whether the given object is callable' do
      expect(PyBind.callable?(PyBind.eval('str'))).to eq(true)
      expect(PyBind.callable?(PyBind.eval('object()'))).to eq(false)
      expect(PyBind.callable?(PyBind::LibPython.PyDict_Type)).to eq(true)
      expect(PyBind.callable?(PyBind::PyDict.new('a' => 1))).to eq(false)
      expect { PyBind.callable?(42) }.to raise_error(TypeError, /can not convert .* to a PyObjectStruct/)
    end
  end

  describe '.dir' do
    it 'calls global dir function' do
      expect(PyBind.dir(PyBind.eval('object()'))).to include('__class__')
    end
  end

  describe 'sys.argv' do
    subject { PyBind.sys.argv }
    it { is_expected.to eq(['']) }
  end

  describe 'PYTHON environment variable' do
    pending
  end

  describe 'LIBPYTHON environment variable' do
    pending
  end
end

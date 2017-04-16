RSpec.shared_context 'Save and restore original python type map' do
  around do |example|
    begin
      original = PyBind::TypeCast.instance_variable_get(:@python_type_map)
      PyBind::TypeCast.instance_variable_set(:@python_type_map, original.dup)
      example.run
    ensure
      PyBind::TypeCast.instance_variable_set(:@python_type_map, original)
    end
  end
end

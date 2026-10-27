# frozen_string_literal: true

# The "Priority levels to show" setting is a multi-select sent to Vikunja as part of the Task
# filter, so Vikunja decides which Tasks come back. These specs show the Recipe keeps the field
# optional and that a selection does not change how the returned Tasks are displayed.
RSpec.describe 'Priority levels setting' do
  let(:field) { YAML.load_file(File.expand_path('../src/settings.yml', __dir__))['custom_fields'].find { |f| f['keyname'] == 'priority_levels' } }

  it 'is a multi-select offering Priorities 0 to 5' do
    expect(field).to include('field_type' => 'select', 'multiple' => true)
    expect(field['options'].flat_map(&:values)).to eq([0, 1, 2, 3, 4, 5])
  end

  it 'is optional, so an empty selection shows every level' do
    expect(field['optional']).to be(true)
  end

  it 'still renders Tasks when levels are selected' do
    screen = render_tasks([build_task(1, title: 'Urgent thing', priority: 4)], custom_fields: CUSTOM_FIELDS.merge(priority_levels: %w[4 5]))

    expect(screen).to have_text('Urgent thing')
  end
end

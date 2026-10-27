# frozen_string_literal: true

require 'yaml'

# How the settings form is organised: groups, the mode switch, and which controls apply to which mode.
RSpec.describe 'Settings definition' do
  let(:fields) { YAML.safe_load_file(File.join(__dir__, '..', 'src', 'settings.yml'))['custom_fields'] }
  let(:by_key) { fields.to_h { |f| [f['keyname'], f] } }
  let(:mode) { by_key.fetch('task_source_mode') }

  it 'puts the mode and the filter controls under Filter options, mode first' do
    filter_fields = fields.select { |f| f['group'] == 'Filter options' }
    expect(filter_fields.map { |f| f['keyname'] }).to eq(%w[task_source_mode custom_filter project_names priority_levels])
  end

  it 'puts Group by Project under Display options' do
    expect(by_key.fetch('group_by_project')['group']).to eq('Display options')
  end

  it 'leaves the connection settings ungrouped' do
    expect(by_key.values_at('base_url', 'api_token').map { |f| f['group'] }).to eq([nil, nil])
  end

  it 'offers Standard (the default) and Custom filter modes' do
    expect(mode['options']).to eq([{ 'Standard' => 'standard' }, { 'Custom filter' => 'custom_filter' }])
    expect(mode['default']).to eq('standard')
  end

  it 'hides the Project and Priority controls in custom mode and shows the filter text only there' do
    rules = mode['conditional_validation'].to_h { |r| [r['when'], r] }
    expect(rules.fetch('custom_filter')['hidden']).to contain_exactly('project_names', 'priority_levels')
    expect(rules.fetch('custom_filter')['visible']).to eq(['custom_filter'])
  end

  it 'marks every conditionally shown control optional' do
    %w[custom_filter project_names priority_levels].each { |k| expect(by_key.fetch(k)['optional']).to be(true) }
  end

  it 'labels every filter control with the mode it applies to' do
    expect(by_key.fetch('custom_filter')['description']).to include('Custom filter mode only.')
    %w[project_names priority_levels].each { |k| expect(by_key.fetch(k)['description']).to include('Standard mode only.') }
  end
end

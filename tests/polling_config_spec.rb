# frozen_string_literal: true

require 'yaml'
require 'uri'

# What the Recipe asks Vikunja for: the polled URLs rendered from src/settings.yml, plus how the settings fields are defined.
RSpec.describe 'Polling config' do
  let(:settings) { YAML.safe_load_file(File.join(__dir__, '..', 'src', 'settings.yml')) }
  let(:fields) { { 'base_url' => 'https://v.example', 'api_token' => 'secret-token' } }
  let(:urls) { Liquid::Template.parse(settings['polling_url']).render(fields).split("\n").map(&:strip).reject(&:empty?) }
  let(:tasks_url) { urls.first }
  let(:tasks_query) { URI.decode_www_form(URI(tasks_url).query) }

  it 'polls over GET' do
    expect(settings['strategy']).to eq('polling')
    expect(settings['polling_verb']).to eq('get')
  end

  it 'refreshes every 15 minutes' do
    expect(settings['refresh_interval']).to eq(15)
  end

  it 'builds both URLs from the base URL setting' do
    expect(urls.map { |u| u.split('?').first }).to eq(%w[https://v.example/api/v1/tasks https://v.example/api/v1/projects])
  end

  it 'requests only open Tasks' do
    expect(tasks_query.to_h['filter']).to start_with('done = false && ')
  end

  it 'sorts by due date ascending then Priority descending' do
    expect(tasks_query.select { |k, _| k == 'sort_by' }.map(&:last)).to eq(%w[due_date priority])
    expect(tasks_query.select { |k, _| k == 'order_by' }.map(&:last)).to eq(%w[asc desc])
  end

  it 'asks for the largest single page of 50 Tasks' do
    expect(tasks_query).to include(%w[per_page 50])
    expect(tasks_query.map(&:first)).not_to include('page')
  end

  describe 'Priority levels filter' do
    def priority_filter(levels) = Liquid::Template.parse(settings['polling_url']).render(fields.merge('priority_levels' => levels))
                                                  .then { |out| URI.decode_www_form(URI(out.split("\n").first.strip).query).to_h['filter'] }

    it 'includes every level when nothing is selected' do
      [nil, []].each do |levels|
        expect(priority_filter(levels)).to eq('done = false && (priority = 0 || priority = 1 || priority = 2 || priority = 3 || priority = 4 || priority = 5)')
      end
    end

    it 'limits the filter to the selected levels' do
      expect(priority_filter(%w[3 4 5])).to eq('done = false && (priority = 3 || priority = 4 || priority = 5)')
    end

    it 'accepts a single level or a comma-separated string' do
      expect(priority_filter('4')).to eq('done = false && (priority = 4)')
      expect(priority_filter('1,2')).to eq('done = false && (priority = 1 || priority = 2)')
    end
  end

  it 'sends the API token as a bearer Authorization header' do
    expect(settings['polling_headers']).to eq('authorization=Bearer {{ api_token }}')
  end

  it 'takes the base URL, API token and grouping as settings, the token as a password field' do
    fields = settings['custom_fields'].reject { |f| f['field_type'] == 'author_bio' }.to_h { |f| [f['keyname'], f] }

    expect(fields.keys).to contain_exactly('base_url', 'api_token', 'project_names', 'priority_levels', 'group_by_project')
    expect(fields['base_url']['field_type']).to eq('string')
    expect(fields['api_token']['field_type']).to eq('password')
  end

  it 'does not hardcode a token' do
    expect(File.read(File.join(__dir__, '..', 'src', 'settings.yml'))).not_to match(/Bearer (?!\{\{)/)
  end
end

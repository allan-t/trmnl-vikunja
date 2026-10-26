# frozen_string_literal: true

require 'yaml'
require 'uri'

# Seam 2: a static check of the polling config in src/settings.yml.
RSpec.describe 'Polling config' do
  let(:settings) { YAML.safe_load_file(File.join(__dir__, '..', 'src', 'settings.yml')) }
  let(:urls) { settings['polling_url'].split("\n").map(&:strip).reject(&:empty?) }
  let(:tasks_url) { urls.first }
  let(:tasks_query) { URI.decode_www_form(URI(tasks_url.sub('{{ base_url }}', 'https://v.example')).query) }

  it 'polls over GET' do
    expect(settings['strategy']).to eq('polling')
    expect(settings['polling_verb']).to eq('get')
  end

  it 'refreshes every 15 minutes' do
    expect(settings['refresh_interval']).to eq(15)
  end

  it 'builds both URLs from the base URL setting' do
    expect(urls).to eq(['{{ base_url }}/api/v1/tasks?filter=done%20%3D%20false&sort_by=due_date&sort_by=priority&order_by=asc&order_by=desc',
                        '{{ base_url }}/api/v1/projects'])
  end

  it 'requests only open Tasks' do
    expect(tasks_query).to include(['filter', 'done = false'])
  end

  it 'sorts by due date ascending then Priority descending' do
    expect(tasks_query.select { |k, _| k == 'sort_by' }.map(&:last)).to eq(%w[due_date priority])
    expect(tasks_query.select { |k, _| k == 'order_by' }.map(&:last)).to eq(%w[asc desc])
  end

  it 'asks for the first page only' do
    expect(tasks_query.map(&:first)).not_to include('page')
  end

  it 'sends the API token as a bearer Authorization header' do
    expect(settings['polling_headers']).to eq('authorization=Bearer {{ api_token }}')
  end

  it 'takes the base URL, API token and grouping as settings, the token as a password field' do
    fields = settings['custom_fields'].reject { |f| f['field_type'] == 'author_bio' }.to_h { |f| [f['keyname'], f] }

    expect(fields.keys).to contain_exactly('base_url', 'api_token', 'group_by_project')
    expect(fields['base_url']['field_type']).to eq('string')
    expect(fields['api_token']['field_type']).to eq('password')
  end

  it 'does not hardcode a token' do
    expect(File.read(File.join(__dir__, '..', 'src', 'settings.yml'))).not_to match(/Bearer (?!\{\{)/)
  end
end

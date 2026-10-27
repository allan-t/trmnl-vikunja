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
    expect(urls.map { |u| u.split('?').first }).to eq(%w[https://v.example/api/v2/tasks https://v.example/api/v2/projects])
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

  describe 'Custom filter mode' do
    let(:custom) { fields.merge('task_source_mode' => 'custom_filter', 'custom_filter' => 'done = false && (priority >= 3 || due_date < now+7d)') }
    let(:out) { Liquid::Template.parse(settings['polling_url']).render(custom).split("\n").map(&:strip).reject(&:empty?) }
    let(:query) { URI.decode_www_form(URI(out.first).query) }

    it 'polls the same request as before in standard mode, set explicitly or not' do
      explicit = Liquid::Template.parse(settings['polling_url']).render(fields.merge('task_source_mode' => 'standard', 'custom_filter' => 'priority = 1'))
      expect(explicit).to eq(Liquid::Template.parse(settings['polling_url']).render(fields))
    end

    it 'sends only the typed filter, with the fixed page size and sort' do
      expect(query).to eq([['per_page', '50'], ['filter', 'done = false && (priority >= 3 || due_date < now+7d)'],
                           %w[sort_by due_date], %w[sort_by priority], %w[order_by asc], %w[order_by desc]])
    end

    it 'encodes every filter character so it survives as a query value' do
      filter = 'a = 1 && b || c < 2 > 1 & (x) + y = "z" #'
      url = Liquid::Template.parse(settings['polling_url']).render(custom.merge('custom_filter' => filter)).split("\n").first.strip
      expect(url.split('filter=').last.split('&sort_by').first).to match(/\A[A-Za-z0-9%+._~-]+\z/)
      expect(URI.decode_www_form(URI(url).query).to_h['filter']).to eq(filter)
    end

    it 'normalises Vikunja UI camelCase field names to API snake_case' do
      filter = 'done = false && dueDate < now+7d && startDate <= now && endDate >= now && doneAt > now-1d && percentDone < 100 && createdBy = "alice"'
      url = Liquid::Template.parse(settings['polling_url']).render(custom.merge('custom_filter' => filter)).split("\n").first.strip

      expect(URI.decode_www_form(URI(url).query).to_h['filter']).to eq(
        'done = false && due_date < now+7d && start_date <= now && end_date >= now && done_at > now-1d && percent_done < 100 && created_by = "alice"'
      )
    end

    ['', '   ', nil].each do |blank|
      it "fetches at most one Task when the filter is blank (#{blank.inspect})" do
        blank_out = Liquid::Template.parse(settings['polling_url']).render(custom.merge('custom_filter' => blank)).split("\n").map(&:strip).reject(&:empty?)
        blank_query = URI.decode_www_form(URI(blank_out.first).query)

        expect(blank_query.first).to eq(%w[per_page 1])
        expect(blank_query.to_h['filter'].to_s.strip).to eq('')
        expect(blank_out.last).to eq('https://v.example/api/v2/projects')
      end
    end

    it 'leaves the Projects request unchanged' do
      expect(out.last).to eq('https://v.example/api/v2/projects')
    end

    it 'ignores Priority levels' do
      with_levels = Liquid::Template.parse(settings['polling_url']).render(custom.merge('priority_levels' => %w[1]))
      expect(with_levels).to eq(Liquid::Template.parse(settings['polling_url']).render(custom))
    end
  end

  it 'sends the API token as a bearer Authorization header' do
    expect(settings['polling_headers']).to eq('authorization=Bearer {{ api_token }}')
  end

  it 'takes the base URL, API token and grouping as settings, the token as a password field' do
    fields = settings['custom_fields'].reject { |f| f['field_type'] == 'author_bio' }.to_h { |f| [f['keyname'], f] }

    expect(fields.keys).to contain_exactly('base_url', 'api_token', 'task_source_mode', 'custom_filter', 'project_names', 'priority_levels',
                                         'group_by_project')
    expect(fields['base_url']['field_type']).to eq('string')
    expect(fields['api_token']['field_type']).to eq('password')
    expect(fields['task_source_mode']['field_type']).to eq('select')
    expect(fields['task_source_mode']['default']).to eq('standard')
    expect(fields['task_source_mode']['options'].flat_map(&:values)).to eq(%w[standard custom_filter])
    expect(fields['custom_filter']['optional']).to be(true)
  end

  it 'does not hardcode a token' do
    expect(File.read(File.join(__dir__, '..', 'src', 'settings.yml'))).not_to match(/Bearer (?!\{\{)/)
  end
end

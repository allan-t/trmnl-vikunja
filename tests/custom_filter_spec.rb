# frozen_string_literal: true

# In custom filter mode Vikunja has already applied the user's filter, so the screen shows what came back:
# the "Projects to show" setting is not applied, while Group by Project still works.
RSpec.describe 'Custom filter mode' do
  let(:tasks) { [build_task(1, title: 'Milk', project_id: 10), build_task(2, title: 'Passport', project_id: 20)] }
  let(:fields) { CUSTOM_FIELDS.merge(task_source_mode: 'custom_filter', custom_filter: 'done = false', project_names: 'Home') }

  it 'applies the Projects to show setting in standard mode' do
    screen = render_tasks(tasks, custom_fields: fields.merge(task_source_mode: 'standard'))

    expect(screen).not_to have_text('Passport')
  end

  LAYOUTS.each do |layout|
    it "ignores the Projects to show setting in the #{layout} layout" do
      screen = render_tasks(tasks, layout:, custom_fields: fields)

      expect(screen).to have_text('Milk')
      expect(screen).to have_text('Passport')
    end
  end

  it 'still groups by Project' do
    screen = render_tasks(tasks, custom_fields: fields.merge(group_by_project: true))

    expect(screen).to have_css('.group-header', text: 'Home')
    expect(screen).to have_css('.group-header', text: 'Admin')
  end

  describe 'when the filter is missing' do
    LAYOUTS.each do |layout|
      ['', '   ', nil].each do |blank|
        it "asks for a filter instead of showing unfiltered Tasks in the #{layout} layout (filter #{blank.inspect})" do
          screen = render_screen(layout:, custom_fields: fields.merge(custom_filter: blank))

          expect(screen).to have_text('Custom filter mode is on but no filter is set. Enter a Vikunja filter in the settings.')
          expect(screen).not_to have_text('Milk')
          expect(screen).not_to have_text(/Could not load tasks|No open tasks/)
        end
      end
    end

    it 'does not fall back to standard filtering' do
      screen = render_screen(custom_fields: fields.merge(custom_filter: '', priority_levels: %w[1]))

      expect(screen).not_to have_text('Buy milk')
      expect(screen).to have_text('no filter is set')
    end
  end

  describe 'when Vikunja rejects the filter' do
    # TRMNL hands the template a failed response's body but not its status; Vikunja's error code says what went wrong.
    def rejection(code) = { status: 400, json: { code:, status: 400, title: 'Bad Request', detail: 'invalid filter' } }

    def render_rejected(code, layout: 'full')
      mocks = vikunja_mocks.merge("#{BASE_URL}/api/v2/tasks" => rejection(code))
      render_screen(layout:, mocks:, custom_fields: fields.merge(custom_filter: 'priority >>> 3'))
    end

    LAYOUTS.each do |layout|
      it "names the custom filter syntax in the #{layout} layout" do
        screen = render_rejected(4024, layout:)

        expect(screen).to have_text('Could not load tasks. Check the custom filter syntax.')
        expect(screen).not_to have_text('secret-token')
      end
    end

    FILTER_ERROR_CODES.each do |code|
      it "recognises Vikunja error #{code} as a filter problem" do
        expect(render_rejected(code)).to have_text('Check the custom filter syntax.')
      end
    end

    it 'keeps the generic message for other 400 errors' do
      expect(render_rejected(2002)).to have_text('Check the Vikunja URL and API token.')
    end

    it 'keeps the generic message for a rejected token, even with a filter set' do
      screen = render_screen(mocks: failing_mocks, custom_fields: fields.merge(custom_filter: 'done = false'))

      expect(screen).to have_text('Could not load tasks. Check the Vikunja URL and API token.')
      expect(screen).not_to have_text('custom filter syntax')
    end

    it 'keeps the generic message when Vikunja is down' do
      screen = render_screen(mocks: { '*' => { status: 500, body: '' } }, custom_fields: fields.merge(custom_filter: 'done = false'))

      expect(screen).to have_text('Check the Vikunja URL and API token.')
    end

    it 'keeps the generic message when only the Projects request fails' do
      mocks = vikunja_mocks.merge("#{BASE_URL}/api/v2/projects" => failing_mocks["#{BASE_URL}/api/v2/projects"])
      screen = render_screen(mocks:, custom_fields: fields.merge(custom_filter: 'done = false'))

      expect(screen).to have_text('Check the Vikunja URL and API token.')
    end

    it 'does not blame the filter in standard mode' do
      mocks = vikunja_mocks.merge("#{BASE_URL}/api/v2/tasks" => rejection(4024))
      screen = render_screen(mocks:, custom_fields: CUSTOM_FIELDS)

      expect(screen).to have_text('Check the Vikunja URL and API token.')
    end
  end

  describe 'when the filter matches nothing' do
    let(:fields) { CUSTOM_FIELDS.merge(task_source_mode: 'custom_filter', custom_filter: 'priority = 5') }

    LAYOUTS.each do |layout|
      it "shows an empty state that does not say open in the #{layout} layout" do
        screen = render_tasks([], layout:, custom_fields: fields)

        expect(screen).to have_text('No tasks match the custom filter')
        expect(screen).not_to have_text(/open/i)
        expect(screen).not_to have_text(/Could not load|no filter is set/)
      end
    end

    it 'leaves the standard mode wording unchanged' do
      expect(render_tasks([], custom_fields: CUSTOM_FIELDS.merge(task_source_mode: 'standard'))).to have_text('No open tasks')
    end
  end
end

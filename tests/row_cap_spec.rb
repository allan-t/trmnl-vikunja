# frozen_string_literal: true

LAYOUTS.each do |layout_name|
  RSpec.describe "#{layout_name} layout row cap" do
    let(:layout) { layout_name }
    let(:cap) { ROW_CAPS.fetch(layout_name) }

    def render_count(count)
      render_tasks((1..count).map { |i| build_task(i, title: format('Chore %02d', i)) }, layout:)
    end

    it 'shows no "+N more" when Tasks are under the cap' do
      screen = render_count(cap - 1)

      expect(screen).to have_text(format('Chore %02d', cap - 1))
      expect(screen).not_to have_text(/more/)
    end

    it 'shows all Tasks and no "+N more" when exactly at the cap' do
      screen = render_count(cap)

      expect(screen).to have_text(format('Chore %02d', cap))
      expect(screen).not_to have_text(/more/)
    end

    it 'caps rows and shows "+N more" in the title bar when over' do
      screen = render_count(cap + 3)

      expect(screen).to have_text(format('Chore %02d', cap))
      expect(screen).not_to have_text(format('Chore %02d', cap + 1))
      expect(screen).to have_css('.title_bar', text: '+3 more')
    end

    it 'does not count group headers toward the cap' do
      tasks = (1..cap + 1).map { |i| build_task(i, title: format('Chore %02d', i), project_id: 10 + (i % 2)) }
      projects = [{ id: 10, title: 'Home' }, { id: 11, title: 'Work' }]
      mocks = vikunja_mocks(tasks:, projects:)
      screen = render_screen(layout:, mocks:, custom_fields: CUSTOM_FIELDS.merge(group_by_project: true))

      expect(screen).to have_css('.task', count: cap)
      expect(screen).to have_text('+1 more')
    end
  end
end

RSpec.describe 'row cap definition' do
  it 'is defined exactly once per Layout' do
    LAYOUTS.each do |layout|
      expect(File.read(File.expand_path("../src/#{layout}.liquid", __dir__)).scan(/row_cap:/).size).to eq(1)
    end
    expect(File.read(File.expand_path('../src/shared.liquid', __dir__))).not_to match(/assign\s+row_cap\s*=/)
  end
end

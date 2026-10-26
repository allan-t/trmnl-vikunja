# frozen_string_literal: true

LAYOUTS.each do |layout|
  RSpec.describe "#{layout} layout" do
    it 'shows each Task with its Project, Priority icon and due label' do
      screen = render_tasks([build_task(title: 'Buy milk', priority: 5, due_date: '2030-01-01T09:00:00Z')], layout:)

      expect(screen).to have_text('Home - Buy milk')
      expect(screen).to have_text('Today')
      expect(screen).to have_text('!!')
    end

    it 'shows the Vikunja Tasks title bar' do
      expect(render_tasks([build_task], layout:)).to have_text('Vikunja Tasks')
    end

    it 'shows "No open tasks" when there are no open Tasks' do
      screen = render_tasks([], layout:)

      expect(screen).to have_text('No open tasks')
      expect(screen).to have_css('.layout.layout--col > .list')
    end

    it 'shows the error message when Vikunja rejects the token' do
      screen = render_screen(layout:, mocks: failing_mocks)

      expect(screen).to have_text(/Could not load tasks/)
      expect(screen).not_to have_text('No open tasks')
      expect(screen).to have_css('.layout.layout--col > .list')
    end
  end
end

# frozen_string_literal: true

# How a Task's Priority (0 to 5) is shown on its row: no icon for 0 and 1, a medium icon for 2 and 3, a
# high icon for 4 and 5.
RSpec.describe 'Full layout' do
  describe 'Priority icons' do
    def screen_for(priority) = render_tasks([build_task(priority, title: "Prio#{priority}", priority:)])

    it 'shows no icon for priorities 0 and 1' do
      [0, 1].each { |p| expect(screen_for(p)).not_to have_text(/!|▲/) }
    end

    it 'shows the medium icon for priorities 2 and 3' do
      [2, 3].each { |p| expect(screen_for(p)).to have_text(/(?<!!)!(?!!).*Prio#{p}/m) }
    end

    it 'shows the high icon for priorities 4 and 5' do
      [4, 5].each { |p| expect(screen_for(p)).to have_text(/!!.*Prio#{p}/m) }
    end
  end
end

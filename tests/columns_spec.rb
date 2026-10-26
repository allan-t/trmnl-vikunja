# frozen_string_literal: true

RSpec.describe 'Layout columns' do
  let(:tasks) { (1..5).map { |i| build_task(i, title: format('Chore %02d', i)) } }

  { 'full' => 2, 'half_horizontal' => 2, 'half_vertical' => 1, 'quadrant' => 1 }.each do |layout, columns|
    it "renders #{layout} in #{columns} column(s)" do
      screen = render_tasks(tasks.first(3), layout:)

      expect(screen).to have_css('.column', count: columns) if columns > 1
      expect(screen).not_to have_css('.column') if columns == 1
      expect(screen).to have_css('.task', count: 3)
    end
  end

  %w[full half_horizontal].each do |layout|
    it "fills the first #{layout} column before the second" do
      screen = render_tasks(tasks, layout:)

      expect(screen).to have_css('.column:nth-child(1) .task', count: 3)
      expect(screen).to have_css('.column:nth-child(1) .task', text: 'Chore 03')
      expect(screen).to have_css('.column:nth-child(2) .task', count: 2)
      expect(screen).to have_css('.column:nth-child(2) .task', text: 'Chore 04')
    end
  end
end

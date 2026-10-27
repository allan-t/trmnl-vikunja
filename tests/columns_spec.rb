# frozen_string_literal: true

# The wide Layouts (full, half_horizontal) flow Tasks through two columns, filling the first before the
# second; the narrow ones (half_vertical, quadrant) use one. These specs show how many columns of Tasks
# each Layout draws on screen.
RSpec.describe 'Layout columns' do
  let(:tasks) { (1..80).map { |i| build_task(i, title: format('Chore %02d', i)) } }

  def column_lefts(screen)
    screen.evaluate("(() => [...new Set([...document.querySelectorAll('.task:not([hidden])')].map((t) => Math.round(t.getBoundingClientRect().left)))].length)()")
  end

  { 'full' => 2, 'half_horizontal' => 2, 'half_vertical' => 1, 'quadrant' => 1 }.each do |layout, columns|
    it "draws #{layout} Tasks in #{columns} column(s)" do
      expect(column_lefts(render_tasks(tasks, layout:))).to eq(columns)
    end
  end
end

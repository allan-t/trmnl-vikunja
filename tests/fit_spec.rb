# frozen_string_literal: true

# Every Layout fits as many Tasks as its screen has room for, hides the rest and says how many
# are hidden ("+N more" in the title bar). These specs render real screens in Firefox and ask the
# live page what is visible, because the fitting script hides rows after the first paint.
LAYOUTS.each do |layout_name|
  RSpec.describe "#{layout_name} layout fitting" do
    let(:layout) { layout_name }

    def many(count) = (1..count).map { |i| build_task(i, title: format('Chore %02d', i)) }

    def shown(screen) = screen.evaluate("(() => document.querySelectorAll('.task:not([hidden])').length)()")

    def more_label(screen) = screen.evaluate("(() => { const el = document.querySelector('.overflow-count'); return el.hidden ? '' : el.textContent; })()")

    it 'shows every Task and no "+N more" when they all fit' do
      screen = render_tasks(many(1), layout:)

      expect(shown(screen)).to eq(1)
      expect(more_label(screen)).to eq('')
    end

    it 'hides Tasks that do not fit and counts them in the title bar' do
      screen = render_tasks(many(80), layout:)
      visible = shown(screen)

      expect(visible).to be > 0
      expect(visible).to be < 80
      expect(more_label(screen)).to eq("+#{80 - visible} more")
    end

    it 'does not draw anything past the edge of the screen' do
      expect(render_tasks(many(80), layout:).overflowing).to be_empty
    end
  end
end

RSpec.describe 'Fitting across Layouts' do
  it 'shows more Tasks on a bigger Layout' do
    tasks = (1..80).map { |i| build_task(i, title: "Chore #{i}") }
    count = ->(layout) { render_tasks(tasks, layout:).evaluate("(() => document.querySelectorAll('.task:not([hidden])').length)()") }

    expect(count.call('full')).to be > count.call('quadrant')
  end

  it 'never leaves a Project header without a Task beneath it' do
    tasks = (1..40).map { |i| build_task(i, title: "Chore #{i}", project_id: 10 + (i % 3) * 10) }
    screen = render_tasks(tasks, layout: 'quadrant', custom_fields: grouped_fields)
    script = "(() => [...document.querySelectorAll('.group-header:not([hidden])')].every((h) => h.nextElementSibling && !h.nextElementSibling.hidden))()"

    expect(screen.evaluate(script)).to be(true)
  end
end

RSpec.describe 'Fit script start-up' do
  let(:shared) { File.read(File.expand_path('../src/shared.liquid', __dir__)) }

  it 'fits on DOMContentLoaded, not on the window load event' do
    expect(shared).to include("addEventListener('DOMContentLoaded'")
    expect(shared).not_to match(/addEventListener\(\s*['"]load['"]/)
  end
end

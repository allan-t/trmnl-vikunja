# frozen_string_literal: true

# In a multi-column flow a Project header must never be the last line of a column with its Tasks starting the next one.
SCREENS_UNDER_TEST = {
  'TRMNL OG' => { device: 'og_png' },
  'TRMNL X landscape' => { device: 'v2' },
  'TRMNL X portrait' => { device: 'v2', orientation: :portrait }
}.freeze

ORPHAN_SCRIPT = <<~JS
  (() => [...document.querySelectorAll('.group-header:not([hidden])')].filter((header) => {
    const next = header.nextElementSibling;
    return next && !next.hidden && next.getBoundingClientRect().left > header.getBoundingClientRect().left + 1;
  }).map((header) => header.textContent.trim()))()
JS

LAYOUTS.each do |layout_name|
  SCREENS_UNDER_TEST.each do |screen_name, screen|
    RSpec.describe "#{layout_name} layout on #{screen_name}" do
      it 'keeps every Project header in the same column as its first Task' do
        projects = (1..14).map { |i| { id: i * 10, title: format('Project %02d', i) } }
        [7, 11, 16, 23, 31].each do |count|
          tasks = (1..count).map { |i| build_task(i, title: format('Chore %02d', i), project_id: (((i - 1) / 2) + 1) * 10) }
          page = render_screen(layout: layout_name, custom_fields: grouped_fields, mocks: vikunja_mocks(tasks:, projects:), **screen)

          expect(page.evaluate(ORPHAN_SCRIPT)).to be_empty, "orphaned header with #{count} Tasks"
        end
      end
    end
  end
end

SCREENS_UNDER_TEST.each do |screen_name, screen|
  %w[full half_horizontal].each do |layout_name|
    RSpec.describe "#{layout_name} layout grouped on #{screen_name}" do
      it 'uses both columns when every Task fits' do
        projects = (1..4).map { |i| { id: i * 10, title: format('Project %02d', i) } }
        tasks = (1..8).map { |i| build_task(i, title: format('Chore %02d', i), project_id: (((i - 1) / 2) + 1) * 10) }
        page = render_screen(layout: layout_name, custom_fields: grouped_fields, mocks: vikunja_mocks(tasks:, projects:), **screen)
        lefts = page.evaluate("(() => [...document.querySelectorAll('.task:not([hidden])')].map((t) => t.getBoundingClientRect().left / document.documentElement.clientWidth))()")

        expect(lefts.size).to eq(8)
        expect(lefts.max).to be > 0.4
        expect(page.evaluate(ORPHAN_SCRIPT)).to be_empty
      end
    end
  end
end

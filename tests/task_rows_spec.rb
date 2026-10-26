# frozen_string_literal: true

# The full layout rendered from a fixture Vikunja response and a fixed "now".
RSpec.describe 'Full layout rows' do
  it 'shows each open Task as "Project - Task" in request order' do
    expect(render_screen).to have_text(/Admin - Renew passport.*Home - Buy milk.*Work - Write report/m)
  end

  it 'shows just the Task title when its Project cannot be resolved' do
    screen = render_tasks([build_task(1, title: 'Orphan', project_id: 999)])

    expect(screen).to have_text('Orphan')
    expect(screen).not_to have_text(/- Orphan/)
  end

  it 'lists undated Tasks last, keeping the given order otherwise' do
    tasks = [build_task(1, title: 'Undated A'), build_task(2, title: 'Dated B', due_date: '2030-01-05T09:00:00Z'),
             build_task(3, title: 'Undated C'), build_task(4, title: 'Dated D', due_date: '2030-01-06T09:00:00Z')]

    expect(render_tasks(tasks)).to have_text(/Dated B.*Dated D.*Undated A.*Undated C/m)
  end
end

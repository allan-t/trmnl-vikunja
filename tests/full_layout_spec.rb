# frozen_string_literal: true

# Seam 1: the full layout rendered from a fixture Vikunja response and a fixed "now".
RSpec.describe 'Full layout' do
  let(:custom_fields) { { base_url: BASE_URL, api_token: 'secret-token' } }

  def render(mocks: vikunja_mocks) = trmnl.render(now: FIXED_NOW, custom_fields:, mocks:)

  it 'shows each open Task as "Project - Task" in request order' do
    screen = render

    expect(screen).to have_text(/Admin - Renew passport.*Home - Buy milk.*Work - Write report/m)
  end
end

RSpec.describe 'Full layout row cap' do
  let(:custom_fields) { { base_url: BASE_URL, api_token: 'secret-token' } }

  def tasks_of(count) = (1..count).map { |i| { 'id' => i, 'title' => format('Chore %02d', i), 'project_id' => 10 } }

  def render_count(count)
    trmnl.render(now: FIXED_NOW, custom_fields:, mocks: vikunja_mocks(tasks: tasks_of(count)))
  end

  it 'shows no footer when Tasks are under the cap' do
    screen = render_count(3)

    expect(screen).to have_text('Chore 03')
    expect(screen).not_to have_text(/more/)
  end

  it 'shows all 8 Tasks and no footer when exactly at the cap' do
    screen = render_count(8)

    expect(screen).to have_text('Chore 08')
    expect(screen).not_to have_text(/more/)
  end

  it 'caps rows at 8 and shows "+N more" with the hidden count when over' do
    screen = render_count(11)

    expect(screen).to have_text('Chore 08')
    expect(screen).not_to have_text('Chore 09')
    expect(screen).to have_text('+3 more')
  end
end

# frozen_string_literal: true

RSpec.describe 'Full layout states' do
  it 'shows "No open tasks" when there are no open Tasks' do
    expect(render_tasks([])).to have_text('No open tasks')
  end

  it 'shows an error message when Vikunja rejects the token' do
    screen = render_screen(mocks: failing_mocks)

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
    expect(screen).not_to have_text('secret-token')
  end

  it 'shows an error message when only the Projects request fails' do
    mocks = vikunja_mocks.merge("#{BASE_URL}/api/v1/projects" => failing_mocks["#{BASE_URL}/api/v1/projects"])
    screen = render_screen(mocks:)

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('Buy milk')
  end

  it 'shows an error message when Vikunja is down' do
    screen = render_screen(mocks: { '*' => { status: 500, body: '' } })

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
  end
end

# frozen_string_literal: true

# Seam 1: the full layout rendered from a fixture Vikunja response and a fixed "now".
RSpec.describe 'Full layout' do
  let(:custom_fields) { { base_url: BASE_URL, api_token: 'secret-token' } }

  def render(mocks: vikunja_mocks) = trmnl.render(now: FIXED_NOW, custom_fields:, mocks:)

  it 'shows each open Task as "Project - Task" in request order' do
    screen = render

    expect(screen).to have_text(/Admin - Renew passport.*Home - Buy milk.*Work - Write report/m)
  end

  it 'shows "No open tasks" when there are no open Tasks' do
    expect(render(mocks: vikunja_mocks(tasks: []))).to have_text('No open tasks')
  end

  it 'shows an error message when Vikunja rejects the token' do
    mocks = {
      "#{BASE_URL}/api/v1/tasks" => { status: 401, json: { code: 1011, message: 'invalid token' } },
      "#{BASE_URL}/api/v1/projects" => { status: 401, json: { code: 1011, message: 'invalid token' } }
    }
    screen = render(mocks:)

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
    expect(screen).not_to have_text('secret-token')
  end

  it 'shows an error message when Vikunja is down' do
    screen = render(mocks: { '*' => { status: 500, body: '' } })

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
  end
end

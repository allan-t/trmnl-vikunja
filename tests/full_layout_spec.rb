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

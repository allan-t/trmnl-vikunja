# frozen_string_literal: true

# Seam 1: the full layout rendered from a fixture Vikunja response and a fixed "now".
RSpec.describe 'Full layout' do
  let(:custom_fields) { { base_url: BASE_URL, api_token: 'secret-token' } }

  def render(mocks: vikunja_mocks) = trmnl.render(now: FIXED_NOW, custom_fields:, mocks:)

  it 'shows each open Task as "Project - Task" in request order' do
    screen = render

    expect(screen).to have_text(/Admin - Renew passport.*Home - Buy milk.*Work - Write report/m)
  end

  describe 'Priority icons' do
    def task(priority) = { 'id' => 900 + priority, 'title' => "Prio#{priority}", 'project_id' => 1, 'priority' => priority }

    it 'shows no icon for priorities 0 and 1' do
      [0, 1].each { |p| expect(render(mocks: vikunja_mocks(tasks: [task(p)]))).not_to have_text(/!|▲/) }
    end

    it 'shows the medium icon for priorities 2 and 3' do
      [2, 3].each { |p| expect(render(mocks: vikunja_mocks(tasks: [task(p)]))).to have_text(/(?<!!)!(?!!).*Prio#{p}/m) }
    end

    it 'shows the high icon for priorities 4 and 5' do
      [4, 5].each { |p| expect(render(mocks: vikunja_mocks(tasks: [task(p)]))).to have_text(/!!.*Prio#{p}/m) }
    end
  end
end

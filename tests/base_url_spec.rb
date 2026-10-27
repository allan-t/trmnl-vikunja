# frozen_string_literal: true

# The Base URL setting is optional: blank means Vikunja Cloud, and a trailing slash on a
# self-hosted URL must not break the requests. These specs show which URL the Recipe polls.
RSpec.describe 'Base URL setting' do
  let(:cloud_url) { 'https://app.vikunja.cloud' }
  let(:cloud_mocks) do
    { "#{cloud_url}/api/v2/tasks" => { json: paginated([build_task(1, title: 'Cloud task')]) },
      "#{cloud_url}/api/v2/projects" => { json: paginated(fixture_json('projects')) } }
  end

  it 'polls Vikunja Cloud when the Base URL is blank' do
    screen = render_screen(mocks: cloud_mocks, custom_fields: CUSTOM_FIELDS.merge(base_url: ''))

    expect(screen).to have_text('Cloud task')
  end

  it 'polls the given Base URL' do
    expect(render_tasks([build_task(1, title: 'Self-hosted task')])).to have_text('Self-hosted task')
  end

  it 'ignores a trailing slash on the Base URL' do
    screen = render_tasks([build_task(1, title: 'Slash task')], custom_fields: CUSTOM_FIELDS.merge(base_url: "#{BASE_URL}/"))

    expect(screen).to have_text('Slash task')
  end
end

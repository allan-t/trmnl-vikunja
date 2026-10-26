# frozen_string_literal: true

require 'json'

BASE_URL = 'https://vikunja.example.com'
FIXED_NOW = '2030-01-01T08:00:00Z'
LAYOUTS = %w[full half_horizontal half_vertical quadrant].freeze
SHARED_TEMPLATE = File.expand_path('../src/shared.liquid', __dir__)
# Single source of truth: the cap lives in the shared partials; specs read it from there.
ROW_CAP = File.read(SHARED_TEMPLATE)[/assign\s+row_cap\s*=\s*(\d+)/, 1]&.to_i or raise 'row_cap not found in src/shared.liquid'
UNSET_DUE_DATE = '0001-01-01T00:00:00Z'
CUSTOM_FIELDS = { base_url: BASE_URL, api_token: 'secret-token' }.freeze

def fixture_json(name) = JSON.parse(File.read(File.join(__dir__, 'fixtures', "#{name}.json")))

# Mocks for the two polling requests: open Tasks (IDX_0) and Projects (IDX_1).
def vikunja_mocks(tasks: fixture_json('tasks'), projects: fixture_json('projects'))
  {
    "#{BASE_URL}/api/v1/tasks" => { json: tasks },
    "#{BASE_URL}/api/v1/projects" => { json: projects }
  }
end

# A Task as the Vikunja API returns it; Project 10 is "Home" in the Projects fixture.
def build_task(id = 1, **overrides)
  { id:, title: "T#{id}", project_id: 10, done: false, priority: 0, due_date: UNSET_DUE_DATE }.merge(overrides)
end

module RenderHelpers
  def render_screen(layout: 'full', mocks: vikunja_mocks, variables: {}, custom_fields: CUSTOM_FIELDS)
    trmnl.render(view: layout, now: FIXED_NOW, custom_fields:, mocks:, variables:)
  end

  def render_tasks(tasks, **) = render_screen(mocks: vikunja_mocks(tasks:), **)

  def failing_mocks(status: 401)
    body = { status:, json: { code: 1011, message: 'invalid token' } }
    { "#{BASE_URL}/api/v1/tasks" => body, "#{BASE_URL}/api/v1/projects" => body }
  end
end

RSpec.configure { |config| config.include RenderHelpers }

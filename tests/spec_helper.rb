# frozen_string_literal: true

require 'json'

# Shared setup for every spec: fixture Vikunja responses, a fixed clock, a Task builder and the render helpers.

BASE_URL = 'https://vikunja.example.com'
FIXED_NOW = '2030-01-01T08:00:00Z'
LAYOUTS = %w[full half_horizontal half_vertical quadrant].freeze
# Vikunja's invalid filter errors (HTTP 400); the Recipe recognises a rejected filter by these codes.
FILTER_ERROR_CODES = [4016, 4017, 4018, 4019, 4024, 4033].freeze
UNSET_DUE_DATE = '0001-01-01T00:00:00Z'
# Grouping is off so specs read plain "Project - Task" rows; grouping_spec.rb turns it on.
CUSTOM_FIELDS = { base_url: BASE_URL, api_token: 'secret-token', group_by_project: false }.freeze

# CUSTOM_FIELDS with the Group by Project setting switched on (or to value).
def grouped_fields(value = true) = CUSTOM_FIELDS.merge(group_by_project: value)

def fixture_json(name) = JSON.parse(File.read(File.join(__dir__, 'fixtures', "#{name}.json")))

# A v2 collection response: the list sits in `items` (null when empty) next to the pagination fields.
def paginated(items) = { items: items.empty? ? nil : items, page: 1, per_page: 50, total: items.size, total_pages: 1 }

# Mocks for the two polling requests: open Tasks (IDX_0) and Projects (IDX_1).
def vikunja_mocks(tasks: fixture_json('tasks'), projects: fixture_json('projects'))
  {
    "#{BASE_URL}/api/v2/tasks" => { json: paginated(tasks) },
    "#{BASE_URL}/api/v2/projects" => { json: paginated(projects) }
  }
end

# A Task as the Vikunja API returns it; Project 10 is "Home" in the Projects fixture.
def build_task(id = 1, **overrides)
  { id:, title: "T#{id}", project_id: 10, done: false, priority: 0, due_date: UNSET_DUE_DATE }.merge(overrides)
end

module RenderHelpers
  # `screen` picks the device and orientation, e.g. device: 'v2', orientation: :portrait for TRMNL X in portrait.
  def render_screen(layout: 'full', mocks: vikunja_mocks, variables: {}, custom_fields: CUSTOM_FIELDS, **screen)
    trmnl.render(view: layout, now: FIXED_NOW, custom_fields:, mocks:, variables:, **screen)
  end

  def render_tasks(tasks, **) = render_screen(mocks: vikunja_mocks(tasks:), **)

  def failing_mocks(status: 401)
    body = { status:, json: { code: 11, message: 'invalid token' } }
    { "#{BASE_URL}/api/v2/tasks" => body, "#{BASE_URL}/api/v2/projects" => body }
  end
end

RSpec.configure { |config| config.include RenderHelpers }

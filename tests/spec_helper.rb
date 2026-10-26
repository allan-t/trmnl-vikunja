# frozen_string_literal: true

require 'json'

BASE_URL = 'https://vikunja.example.com'
FIXED_NOW = '2030-01-01T08:00:00Z'

def fixture_json(name) = JSON.parse(File.read(File.join(__dir__, 'fixtures', "#{name}.json")))

# Mocks for the two polling requests: open Tasks (IDX_0) and Projects (IDX_1).
def vikunja_mocks(tasks: fixture_json('tasks'), projects: fixture_json('projects'))
  {
    "#{BASE_URL}/api/v1/tasks" => { json: tasks },
    "#{BASE_URL}/api/v1/projects" => { json: projects }
  }
end

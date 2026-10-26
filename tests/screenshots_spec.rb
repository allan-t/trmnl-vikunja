# frozen_string_literal: true

require 'fileutils'

# Regenerates docs/screenshots/<layout>-<grouped|ungrouped>.png from fixed fixture data and a fixed clock.
# Skipped unless SCREENSHOTS=1: run it with bin/screenshots. Needs no Vikunja token.
SCREENSHOT_DIR = File.expand_path('../docs/screenshots', __dir__)
GROUPING_FIELD = :group_by_project

RSpec.describe 'Layout screenshots', if: ENV['SCREENSHOTS'] == '1' do
  let(:mocks) do
    vikunja_mocks(tasks: fixture_json('screenshot_tasks'), projects: fixture_json('screenshot_projects'))
  end

  LAYOUTS.each do |layout|
    { 'grouped' => true, 'ungrouped' => false }.each do |mode, value|
      it "writes #{layout}-#{mode}.png" do
        screen = render_screen(layout:, mocks:, custom_fields: CUSTOM_FIELDS.merge(GROUPING_FIELD => value))
        FileUtils.mkdir_p(SCREENSHOT_DIR)
        FileUtils.cp(screen.png_path, File.join(SCREENSHOT_DIR, "#{layout}-#{mode}.png"))
      end
    end
  end
end

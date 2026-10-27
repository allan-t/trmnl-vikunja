# frozen_string_literal: true

# Runs trmnlp's own checks for a Recipe that can be published, against the fixture Vikunja responses.
RSpec.describe 'TRMNL Vikunja' do
  let(:mocks) { vikunja_mocks }
  let(:custom_fields) { CUSTOM_FIELDS }
  let(:now) { FIXED_NOW }

  it_behaves_like 'a publishable recipe'
end

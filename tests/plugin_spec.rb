# frozen_string_literal: true

RSpec.describe 'TRMNL Vikunja' do
  let(:mocks) { vikunja_mocks }
  let(:custom_fields) { { base_url: BASE_URL, api_token: 'secret-token' } }
  let(:now) { FIXED_NOW }

  it_behaves_like 'a publishable recipe'
end

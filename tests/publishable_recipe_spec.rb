# frozen_string_literal: true

# TRMNL's own publishing checks, the ones reviewers' tooling mirrors: every view on TRMNL OG, OG+, and TRMNL X
# in landscape and portrait, dark mode, API failures and each option of every select and boolean setting.
RSpec.describe 'Publishable Recipe' do
  let(:mocks) { vikunja_mocks }
  let(:custom_fields) { CUSTOM_FIELDS }
  let(:now) { FIXED_NOW }

  it_behaves_like 'a publishable recipe'
end

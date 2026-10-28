# frozen_string_literal: true

require 'yaml'

# CI only checks the repo: it runs tests and lint on pushes to main and on pull requests, and never
# pushes to a live TRMNL Recipe. The release workflow only attaches a zip to a GitHub Release. These specs
# show neither has a deploy step or API key, and that CONTRIBUTING.md does not tell people to set one up.
RSpec.describe 'CI workflow' do
  let(:workflow_path) { File.expand_path('../.github/workflows/test.yml', __dir__) }
  let(:workflow) { File.read(workflow_path) }
  let(:workflow_yaml) { YAML.safe_load(workflow, aliases: true) }
  let(:contributing) { File.read(File.expand_path('../CONTRIBUTING.md', __dir__)) }

  it 'runs validation jobs without a deploy step' do
    expect { workflow_yaml }.not_to raise_error
    expect(workflow).to include('jobs:')
    expect(workflow).to include('test:')
    expect(workflow).to include("on:\n  pull_request:\n  push:\n    branches: [main]\n  workflow_call:")
    expect(workflow).not_to include('deploy:')
    expect(workflow).not_to include('TRMNL_API_KEY')
    expect(workflow).not_to include('trmnlp push')
  end

  it 'only builds a Recipe zip for a GitHub Release when a version tag is pushed, never touching TRMNL' do
    release = File.read(File.expand_path('../.github/workflows/release.yml', __dir__))

    expect(release).to include("tags: ['v*']")
    expect(release).to include('bin/pack')
    expect(release).to include('gh release create')
    expect(release).to include('gh release upload')
    expect(release).not_to include('TRMNL_API_KEY')
    expect(release).not_to include('trmnlp push')
  end

  it 'documents that CI only checks the repo and never pushes to TRMNL' do
    expect(contributing).to include('CI')
    expect(contributing).to include('lint')
    expect(contributing).not_to include('private plugin')
    expect(contributing).not_to include('TRMNL_API_KEY')
  end
end

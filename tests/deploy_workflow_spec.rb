# frozen_string_literal: true

require 'yaml'

RSpec.describe 'deployment workflow gates' do
  let(:workflow_path) { File.expand_path('../.github/workflows/test.yml', __dir__) }
  let(:workflow) { File.read(workflow_path) }
  let(:workflow_yaml) { YAML.safe_load(workflow, aliases: true) }
  let(:readme) { File.read(File.expand_path('../README.md', __dir__)) }

  it 'keeps the test and deploy jobs in the same workflow' do
    expect { workflow_yaml }.not_to raise_error
    expect(workflow).to include('jobs:')
    expect(workflow).to include('test:')
    expect(workflow).to include('deploy:')
  end

  it 'deploys only on pushes to main and never on pull requests' do
    expect(workflow).to include("on:\n  push:\n    branches: [main]")
    expect(workflow).not_to include('pull_request:')
  end

  it 'requires the deploy job to wait for the test job' do
    expect(workflow).to include("  deploy:\n    needs: test")
  end

  it 'uses the repository secret for the API key without storing a literal secret' do
    expect(workflow).to include('TRMNL_API_KEY: ${{ secrets.TRMNL_API_KEY }}')
    expect(workflow).not_to match(/TRMNL_API_KEY:\s*['"][^'"]+['"]/)
  end

  it 'fails before deploying if the plugin id is not set' do
    expect(workflow).to include("grep -q '^id: 520678$' src/settings.yml")
  end

  it 'documents the private-plugin deploy safety rules in the repo docs' do
    expect(readme).to include('private plugin')
    expect(readme).to include('source of truth')
    expect(readme).to include('sync-bot')
    expect(readme).to include('plugin id contract')
    expect(readme).to include('first deploy')
  end
end

# frozen_string_literal: true

require 'yaml'

RSpec.describe 'CI workflow' do
  let(:workflow_path) { File.expand_path('../.github/workflows/test.yml', __dir__) }
  let(:workflow) { File.read(workflow_path) }
  let(:workflow_yaml) { YAML.safe_load(workflow, aliases: true) }
  let(:readme) { File.read(File.expand_path('../README.md', __dir__)) }

  it 'runs validation jobs without a deploy step' do
    expect { workflow_yaml }.not_to raise_error
    expect(workflow).to include('jobs:')
    expect(workflow).to include('test:')
    expect(workflow).to include("on:\n  pull_request:\n  push:\n    branches: [main]")
    expect(workflow).not_to include('deploy:')
    expect(workflow).not_to include('TRMNL_API_KEY')
    expect(workflow).not_to include('trmnlp push')
  end

  it 'documents that CI only checks the repo and never pushes to TRMNL' do
    expect(readme).to include('CI')
    expect(readme).to include('lint')
    expect(readme).not_to include('private plugin')
    expect(readme).not_to include('TRMNL_API_KEY')
  end
end

# frozen_string_literal: true

# bin/pack builds the importable zip. It must never ship the private plugin id from settings.yml, or an import
# would point at the existing private plugin instead of creating a new Recipe.
RSpec.describe 'Recipe zip packaging' do
  let(:root) { File.expand_path('..', __dir__) }
  let(:pack) { File.read(File.join(root, 'bin', 'pack')) }
  let(:settings) { File.read(File.join(root, 'src', 'settings.yml')) }

  it 'strips the plugin id line from settings.yml' do
    pattern = pack[%r{\.sub\(/(.+?)/, ""\)}, 1]

    expect(settings).to match(/^id: \d+$/)
    expect(pattern).not_to be_nil
    expect(settings.sub(Regexp.new(pattern), '')).not_to match(/^id:/)
  end
end

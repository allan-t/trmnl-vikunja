# frozen_string_literal: true

# The title bar carries a Vikunja icon instead of TRMNL's default logo. It is encoded in the page, so it
# renders without an external request, and it is black and white so it survives the 1-bit palette.
LAYOUTS.each do |layout_name|
  RSpec.describe "#{layout_name} title bar" do
    let(:screen) { render_tasks([build_task(1, title: 'Buy milk')], layout: layout_name) }

    it 'shows an inline Vikunja icon beside the title' do
      src = screen.evaluate("(() => document.querySelector('.title_bar img.image')?.getAttribute('src'))()")

      expect(src).to start_with('data:image/svg+xml;base64,')
    end

    it 'keeps the title text' do
      expect(screen).to have_text('Vikunja Tasks')
    end
  end
end

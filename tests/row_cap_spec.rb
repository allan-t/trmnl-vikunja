# frozen_string_literal: true

RSpec.describe 'Full layout row cap' do
  def render_count(count)
    render_tasks((1..count).map { |i| build_task(i, title: format('Chore %02d', i)) })
  end

  it 'shows no footer when Tasks are under the cap' do
    screen = render_count(3)

    expect(screen).to have_text('Chore 03')
    expect(screen).not_to have_text(/more/)
  end

  it 'shows all Tasks and no footer when exactly at the cap' do
    screen = render_count(ROW_CAP)

    expect(screen).to have_text(format('Chore %02d', ROW_CAP))
    expect(screen).not_to have_text(/more/)
  end

  it 'caps rows and shows "+N more" with the hidden count when over' do
    screen = render_count(ROW_CAP + 3)

    expect(screen).to have_text(format('Chore %02d', ROW_CAP))
    expect(screen).not_to have_text(format('Chore %02d', ROW_CAP + 1))
    expect(screen).to have_text('+3 more')
  end

  describe 'cap definition' do
    it 'is defined exactly once in the template' do
      expect(File.read(FULL_TEMPLATE).scan(/assign\s+row_cap\b/).size).to eq(1)
    end

    it 'matches the cap the template actually applies' do
      screen = render_count(ROW_CAP + 1)

      expect(screen).to have_text(format('Chore %02d', ROW_CAP))
      expect(screen).not_to have_text(format('Chore %02d', ROW_CAP + 1))
      expect(screen).to have_text('+1 more')
    end
  end
end

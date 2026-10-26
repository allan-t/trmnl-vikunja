# frozen_string_literal: true

# Seam 1: the full layout rendered from a fixture Vikunja response and a fixed "now".
RSpec.describe 'Full layout' do
  it 'shows each open Task as "Project - Task" in request order' do
    expect(render_screen).to have_text(/Admin - Renew passport.*Home - Buy milk.*Work - Write report/m)
  end

  it 'shows just the Task title when its Project cannot be resolved' do
    screen = render_tasks([build_task(1, title: 'Orphan', project_id: 999)])

    expect(screen).to have_text('Orphan')
    expect(screen).not_to have_text(/- Orphan/)
  end

  describe 'Priority icons' do
    def screen_for(priority) = render_tasks([build_task(priority, title: "Prio#{priority}", priority:)])

    it 'shows no icon for priorities 0 and 1' do
      [0, 1].each { |p| expect(screen_for(p)).not_to have_text(/!|▲/) }
    end

    it 'shows the medium icon for priorities 2 and 3' do
      [2, 3].each { |p| expect(screen_for(p)).to have_text(/(?<!!)!(?!!).*Prio#{p}/m) }
    end

    it 'shows the high icon for priorities 4 and 5' do
      [4, 5].each { |p| expect(screen_for(p)).to have_text(/!!.*Prio#{p}/m) }
    end
  end

  describe 'due date labels' do
    def labels_for(due, **) = render_tasks([build_task(1, due_date: due)], **)

    it('says Today for a due date later today') { expect(labels_for('2030-01-01T18:00:00Z')).to have_text('Today') }
    it('says Tomorrow for the next day') { expect(labels_for('2030-01-02T09:00:00Z')).to have_text('Tomorrow') }
    it('says Overdue 1d for yesterday') { expect(labels_for('2029-12-31T09:00:00Z')).to have_text('Overdue 1d') }
    it('says Overdue 5d for five days ago') { expect(labels_for('2029-12-27T09:00:00Z')).to have_text('Overdue 5d') }
    it('shows an absolute date for far dates') { expect(labels_for('2030-11-12T09:00:00Z')).to have_text('12 Nov') }

    it 'shows no date line for an unset due date' do
      expect(labels_for(UNSET_DUE_DATE)).not_to have_text(/Today|Tomorrow|Overdue|Jan/)
    end

    it 'treats any pre-1970 due date as unset' do
      expect(labels_for('0000-12-30T00:00:00Z')).not_to have_text(/Today|Tomorrow|Overdue|Jan|Dec/)
    end

    describe "in the user's time zone" do
      def offset(seconds) = { trmnl: { user: { utc_offset: seconds } } }

      it 'says Tomorrow when the due date is already the next day locally (east of UTC)' do
        expect(labels_for('2030-01-01T20:00:00Z', variables: offset(10 * 3600))).to have_text('Tomorrow')
      end

      it 'says Today when the due date is still the same day locally (west of UTC)' do
        expect(labels_for('2030-01-01T05:00:00Z', variables: offset(-9 * 3600))).to have_text('Today')
      end

      it 'shows the absolute date in local time' do
        expect(labels_for('2030-11-12T23:00:00Z', variables: offset(10 * 3600))).to have_text('13 Nov')
      end

      it 'falls back to UTC when the offset is not available' do
        expect(labels_for('2030-01-01T20:00:00Z', variables: { trmnl: { user: { utc_offset: nil } } }))
          .to have_text('Today')
      end
    end
  end

  it 'lists undated Tasks last, keeping the given order otherwise' do
    tasks = [build_task(1, title: 'Undated A'), build_task(2, title: 'Dated B', due_date: '2030-01-05T09:00:00Z'),
             build_task(3, title: 'Undated C'), build_task(4, title: 'Dated D', due_date: '2030-01-06T09:00:00Z')]

    expect(render_tasks(tasks)).to have_text(/Dated B.*Dated D.*Undated A.*Undated C/m)
  end

  it 'shows "No open tasks" when there are no open Tasks' do
    expect(render_tasks([])).to have_text('No open tasks')
  end

  it 'shows an error message when Vikunja rejects the token' do
    screen = render_screen(mocks: failing_mocks)

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
    expect(screen).not_to have_text('secret-token')
  end

  it 'shows an error message when only the Projects request fails' do
    mocks = vikunja_mocks.merge("#{BASE_URL}/api/v1/projects" => failing_mocks["#{BASE_URL}/api/v1/projects"])
    screen = render_screen(mocks:)

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('Buy milk')
  end

  it 'shows an error message when Vikunja is down' do
    screen = render_screen(mocks: { '*' => { status: 500, body: '' } })

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
  end
end

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
end

# frozen_string_literal: true

# Seam 1: the full layout rendered from a fixture Vikunja response and a fixed "now".
RSpec.describe 'Full layout' do
  let(:custom_fields) { { base_url: BASE_URL, api_token: 'secret-token' } }

  def render(mocks: vikunja_mocks) = trmnl.render(now: FIXED_NOW, custom_fields:, mocks:)

  it 'shows each open Task as "Project - Task" in request order' do
    screen = render

    expect(screen).to have_text(/Admin - Renew passport.*Home - Buy milk.*Work - Write report/m)
  end

  describe 'Priority icons' do
    def task(priority) = { 'id' => 900 + priority, 'title' => "Prio#{priority}", 'project_id' => 1, 'priority' => priority }

    it 'shows no icon for priorities 0 and 1' do
      [0, 1].each { |p| expect(render(mocks: vikunja_mocks(tasks: [task(p)]))).not_to have_text(/!|▲/) }
    end

    it 'shows the medium icon for priorities 2 and 3' do
      [2, 3].each { |p| expect(render(mocks: vikunja_mocks(tasks: [task(p)]))).to have_text(/(?<!!)!(?!!).*Prio#{p}/m) }
    end

    it 'shows the high icon for priorities 4 and 5' do
      [4, 5].each { |p| expect(render(mocks: vikunja_mocks(tasks: [task(p)]))).to have_text(/!!.*Prio#{p}/m) }
    end
  end


  def task(id, due, title: "T#{id}") = { id:, title:, project_id: 10, done: false, priority: 0, due_date: due }
  def labels_for(due) = render(mocks: vikunja_mocks(tasks: [task(1, due)]))

  describe 'due date labels' do
    it('says Today for a due date later today') { expect(labels_for('2030-01-01T18:00:00Z')).to have_text('Today') }
    it('says Tomorrow for the next day') { expect(labels_for('2030-01-02T09:00:00Z')).to have_text('Tomorrow') }
    it('says Overdue 1d for yesterday') { expect(labels_for('2029-12-31T09:00:00Z')).to have_text('Overdue 1d') }
    it('says Overdue 5d for five days ago') { expect(labels_for('2029-12-27T09:00:00Z')).to have_text('Overdue 5d') }
    it('shows an absolute date for far dates') { expect(labels_for('2030-11-12T09:00:00Z')).to have_text('12 Nov') }

    it 'shows no date line for an unset due date' do
      screen = labels_for('0001-01-01T00:00:00Z')

      expect(screen).not_to have_text(/Today|Tomorrow|Overdue|Jan/)
    end
  end

  it 'lists undated Tasks last, keeping the given order otherwise' do
    tasks = [task(1, '0001-01-01T00:00:00Z', title: 'Undated A'), task(2, '2030-01-05T09:00:00Z', title: 'Dated B'),
             task(3, '0001-01-01T00:00:00Z', title: 'Undated C'), task(4, '2030-01-06T09:00:00Z', title: 'Dated D')]

    expect(render(mocks: vikunja_mocks(tasks:))).to have_text(/Dated B.*Dated D.*Undated A.*Undated C/m)
  end

  it 'shows "No open tasks" when there are no open Tasks' do
    expect(render(mocks: vikunja_mocks(tasks: []))).to have_text('No open tasks')
  end

  it 'shows an error message when Vikunja rejects the token' do
    mocks = {
      "#{BASE_URL}/api/v1/tasks" => { status: 401, json: { code: 1011, message: 'invalid token' } },
      "#{BASE_URL}/api/v1/projects" => { status: 401, json: { code: 1011, message: 'invalid token' } }
    }
    screen = render(mocks:)

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
    expect(screen).not_to have_text('secret-token')
  end

  it 'shows an error message when Vikunja is down' do
    screen = render(mocks: { '*' => { status: 500, body: '' } })

    expect(screen).to have_text(/Could not load tasks/)
    expect(screen).not_to have_text('No open tasks')
  end
end

RSpec.describe 'Full layout row cap' do
  let(:custom_fields) { { base_url: BASE_URL, api_token: 'secret-token' } }

  def tasks_of(count) = (1..count).map { |i| { 'id' => i, 'title' => format('Chore %02d', i), 'project_id' => 10 } }

  def render_count(count)
    trmnl.render(now: FIXED_NOW, custom_fields:, mocks: vikunja_mocks(tasks: tasks_of(count)))
  end

  it 'shows no footer when Tasks are under the cap' do
    screen = render_count(3)

    expect(screen).to have_text('Chore 03')
    expect(screen).not_to have_text(/more/)
  end

  it 'shows all 8 Tasks and no footer when exactly at the cap' do
    screen = render_count(8)

    expect(screen).to have_text('Chore 08')
    expect(screen).not_to have_text(/more/)
  end

  it 'caps rows at 8 and shows "+N more" with the hidden count when over' do
    screen = render_count(11)

    expect(screen).to have_text('Chore 08')
    expect(screen).not_to have_text('Chore 09')
    expect(screen).to have_text('+3 more')
  end
end

# frozen_string_literal: true

# The "Projects to show" setting limits the display to Tasks from the named Projects.
# These specs show which Tasks appear for different settings, including an empty or non-matching list.
RSpec.describe 'Project filter' do
  let(:tasks) do
    [build_task(1, title: 'Milk', project_id: 10), build_task(2, title: 'Passport', project_id: 20),
     build_task(3, title: 'Report', project_id: 30)]
  end

  def with_projects(names, **) = render_tasks(tasks, custom_fields: CUSTOM_FIELDS.merge(project_names: names), **)

  it 'shows every Project when the setting is empty' do
    ['', nil].each { |names| expect(with_projects(names)).to have_text(/Milk.*Passport.*Report/m) }
  end

  it 'shows only Tasks from the listed Projects' do
    screen = with_projects('Home, Work')

    expect(screen).to have_text('Milk')
    expect(screen).to have_text('Report')
    expect(screen).not_to have_text('Passport')
  end

  it 'matches names regardless of case and surrounding spaces' do
    expect(with_projects('  admin ')).to have_text('Passport')
  end

  it 'ignores a name that matches no Project' do
    screen = with_projects('Home, Nonsense')

    expect(screen).to have_text('Milk')
    expect(screen).not_to have_text('Report')
  end

  it 'explains an empty screen when no listed Project matches' do
    expect(with_projects('Nonsense')).to have_text('No open tasks in the selected Projects')
  end

  it 'only gives headers to the listed Projects when grouped' do
    screen = render_tasks(tasks, custom_fields: grouped_fields.merge(project_names: 'Home'))

    expect(screen).to have_css('.group-header', count: 1, text: 'Home')
  end
end

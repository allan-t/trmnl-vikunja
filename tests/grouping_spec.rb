# frozen_string_literal: true

RSpec.describe 'Grouping setting' do
  let(:tasks) do
    [build_task(1, title: 'Passport', project_id: 20), build_task(2, title: 'Milk', project_id: 10),
     build_task(3, title: 'Tax', project_id: 20), build_task(4, title: 'Report', project_id: 30)]
  end

  def grouped(layout: 'full', value: true) = render_tasks(tasks, layout:, custom_fields: CUSTOM_FIELDS.merge(group_by_project: value))

  it 'is declared as a setting defaulting to on' do
    field = YAML.load_file(File.expand_path('../src/settings.yml', __dir__))['custom_fields'].find { |f| f['keyname'] == 'group_by_project' }

    expect(field['default']).to be(true)
  end

  it 'groups Tasks under one header per Project, in urgency order within each group' do
    screen = grouped(layout: 'half_vertical')

    expect(screen).to have_css('.group-header', count: 3)
    expect(screen).to have_text(/Admin.*Passport.*Tax.*Home.*Milk.*Work.*Report/m)
  end

  it 'omits the Project name from grouped rows' do
    expect(grouped(layout: 'half_vertical')).not_to have_css('.task-title', text: /Admin - /)
  end

  it 'shows headers only for Projects with shown Tasks' do
    expect(grouped).not_to have_text('Nothing Project')
    expect(render_tasks([build_task(1)], custom_fields: CUSTOM_FIELDS.merge(group_by_project: true))).to have_css('.group-header', count: 1)
  end

  it 'groups by default when the setting is unset' do
    expect(render_tasks(tasks, layout: 'half_vertical', custom_fields: CUSTOM_FIELDS.except(:group_by_project))).to have_css('.group-header', count: 3)
  end

  it 'lists one urgency-ordered list of "Project - Task" rows when off' do
    screen = grouped(layout: 'half_vertical', value: false)

    expect(screen).not_to have_css('.group-header')
    expect(screen).to have_text(/Admin - Passport.*Home - Milk.*Admin - Tax.*Work - Report/m)
  end

  LAYOUTS.each do |layout|
    it "groups on #{layout}" do
      expect(grouped(layout:)).to have_css('.group-header')
    end
  end

  it 'repeats a header when a group continues into the second column' do
    many = (1..4).map { |i| build_task(i, title: "Chore #{i}", project_id: 10) }
    screen = render_tasks(many, layout: 'full', custom_fields: CUSTOM_FIELDS.merge(group_by_project: true))

    expect(screen).to have_css('.column:nth-child(1) .group-header', text: 'Home')
    expect(screen).to have_css('.column:nth-child(2) .group-header', text: 'Home')
  end
end

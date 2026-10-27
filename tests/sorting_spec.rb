# frozen_string_literal: true

# Sorting controls for Tasks and grouped Project headers.
RSpec.describe 'Sorting settings' do
  def with_sort(tasks, **overrides)
    render_tasks(tasks, custom_fields: CUSTOM_FIELDS.merge(group_by_project: false).merge(overrides))
  end

  it 'keeps the API order exactly when task sort is unsorted' do
    tasks = [build_task(1, title: 'Undated A', due_date: nil), build_task(2, title: 'Dated B', due_date: '2030-01-02T09:00:00Z'),
             build_task(3, title: 'Dated C', due_date: '2030-01-01T09:00:00Z')]

    screen = with_sort(tasks, task_sort_field: 'unsorted', task_sort_direction: 'desc')
    expect(screen).to have_text(/Undated A.*Dated B.*Dated C/m)
  end

  it 'sorts by due date descending and keeps undated tasks last' do
    tasks = [build_task(1, title: 'Undated A', due_date: nil), build_task(2, title: 'Dated B', due_date: '2030-01-02T09:00:00Z'),
             build_task(3, title: 'Dated C', due_date: '2030-01-01T09:00:00Z')]

    screen = with_sort(tasks, task_sort_field: 'due_date', task_sort_direction: 'desc')
    expect(screen).to have_text(/Dated B.*Dated C.*Undated A/m)
  end

  it 'sorts by project then task title when ungrouped' do
    tasks = [build_task(1, title: 'Zulu', project_id: 20), build_task(2, title: 'Beta', project_id: 10),
             build_task(3, title: 'Alpha', project_id: 10), build_task(4, title: 'Gamma', project_id: 30)]

    screen = with_sort(tasks, task_sort_field: 'project', task_sort_direction: 'asc')
    expect(screen).to have_text(/Admin - Zulu.*Home - Alpha.*Home - Beta.*Work - Gamma/m)
  end

  it 'sorts tasks within each grouped Project only' do
    tasks = [build_task(1, title: 'Milk', project_id: 10), build_task(2, title: 'Zulu', project_id: 20),
             build_task(3, title: 'Alpha', project_id: 20), build_task(4, title: 'Report', project_id: 30)]

    screen = render_tasks(tasks, custom_fields: CUSTOM_FIELDS.merge(group_by_project: true, task_sort_field: 'alphabetical',
                                                                    task_sort_direction: 'asc', project_sort_field: 'unsorted'))
    expect(screen).to have_text(/Home.*Milk.*Admin.*Alpha.*Zulu.*Work.*Report/m)
  end

  it 'sorts grouped Project headers alphabetically descending' do
    tasks = [build_task(1, title: 'A', project_id: 20), build_task(2, title: 'B', project_id: 10), build_task(3, title: 'C', project_id: 30)]

    screen = render_tasks(tasks, custom_fields: CUSTOM_FIELDS.merge(group_by_project: true, project_sort_field: 'alphabetical',
                                                                    project_sort_direction: 'desc', task_sort_field: 'unsorted'))
    expect(screen).to have_text(/Work.*C.*Home.*B.*Admin.*A/m)
  end

  it 'sorts grouped Project headers by Projects-to-show list order, then alphabetical fallback' do
    tasks = [build_task(1, title: 'A', project_id: 20), build_task(2, title: 'B', project_id: 10), build_task(3, title: 'C', project_id: 30)]

    screen = render_tasks(tasks, custom_fields: CUSTOM_FIELDS.merge(group_by_project: true, project_sort_field: 'project_filter_order',
                                                                    project_sort_direction: 'asc', project_names: 'Work, Home',
                                                                    task_sort_field: 'unsorted', task_source_mode: 'custom_filter',
                                                                    custom_filter: 'done = false'))
    expect(screen).to have_text(/Work.*C.*Home.*B.*Admin.*A/m)
  end
end

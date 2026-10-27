# frozen_string_literal: true

# In custom filter mode Vikunja has already applied the user's filter, so the screen shows what came back:
# the "Projects to show" setting is not applied, while Group by Project still works.
RSpec.describe 'Custom filter mode' do
  let(:tasks) { [build_task(1, title: 'Milk', project_id: 10), build_task(2, title: 'Passport', project_id: 20)] }
  let(:fields) { CUSTOM_FIELDS.merge(task_source_mode: 'custom_filter', project_names: 'Home') }

  it 'applies the Projects to show setting in standard mode' do
    screen = render_tasks(tasks, custom_fields: fields.merge(task_source_mode: 'standard'))

    expect(screen).not_to have_text('Passport')
  end

  LAYOUTS.each do |layout|
    it "ignores the Projects to show setting in the #{layout} layout" do
      screen = render_tasks(tasks, layout:, custom_fields: fields)

      expect(screen).to have_text('Milk')
      expect(screen).to have_text('Passport')
    end
  end

  it 'still groups by Project' do
    screen = render_tasks(tasks, custom_fields: fields.merge(group_by_project: true))

    expect(screen).to have_css('.group-header', text: 'Home')
    expect(screen).to have_css('.group-header', text: 'Admin')
  end
end

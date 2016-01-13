require 'rails_helper'

feature 'New submission' do
  scenario 'can submit manifest via form' do
    visit new_submission_path

    click_link "Submit via form"

    expect(page).to have_content('Submit new manifest')
  end

  scenario 'can submit manifest via upload' do
    visit new_submission_path

    click_link 'Upload scan'

    expect(page).to have_content('Attach a scan of the manifest')
  end
end

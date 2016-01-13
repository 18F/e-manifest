require 'rails_helper'

feature 'Home page' do
  scenario 'sees list of recently filed manifests' do
    manifest = create(:manifest)

    visit root_path

    expect(page).to have_content manifest.tracking_number
    expect(page).to have_content manifest.generator_name
    expect(page).to have_content manifest.created_on
  end

  scenario 'navigates to submit manifest page' do
    visit root_path

    click_link 'Industry'

    expect(page).to have_content 'Submit a manifest'
  end
end
require 'rails_helper'

feature 'Home page' do
  scenario 'sees list of public manifests', elasticsearch: true do
    new_manifest = create(:manifest)
    new_manifest.reload
    new_manifest.reindex
    old_manifest = create(:manifest)
    old_manifest.reload
    old_manifest.update_column(:created_at, 91.days.ago)
    old_manifest.reindex
    Manifest.__elasticsearch__.refresh_index!

    visit root_path

    puts page.body
    expect(page).to have_content old_manifest.tracking_number
    expect(page).to_not have_content new_manifest.tracking_number
  end

  scenario 'navigates to submit manifest page' do
    visit root_path

    click_link 'Industry'

    expect(page).to have_content 'Submit a manifest'
  end
end

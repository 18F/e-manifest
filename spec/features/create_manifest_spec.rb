require 'rails_helper'

feature 'Create manifest' do
  scenario 'successfully' do
    manifest_tracking_number = '12345'
    visit new_manifest_path

    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'

    expect(page).to have_content("Manifest #{manifest_tracking_number} submitted successfully.")
  end
end

require 'rails_helper'

feature 'Upload scan' do
  scenario 'upload instead of filling out form' do
    visit new_manifest_upload_path

    attach_file('manifest[upload]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    expect(page).to have_content("Upload for manifest submitted successfully.")
  end

  scenario 'upload after filling in form' do
    manifest_tracking_number = '12345'
    visit new_manifest_path

    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'
    click_on 'Upload'
    attach_file('manifest[upload]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    expect(page).to have_content("Upload for manifest #{manifest_tracking_number} submitted successfully.")
  end
end

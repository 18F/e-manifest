require 'rails_helper'

feature 'Upload scan', elasticsearch: true do
  scenario 'upload requires authenticated session' do
    visit new_manifest_upload_path
    expect(page).to have_content('You must be logged in to access this page.')
  end
  scenario 'upload instead of filling out form' do
    mock_authenticated_session
    manifest_tracking_number = '987654321abc'
    visit new_manifest_upload_path

    fill_in 'Manifest Tracking Number', with: manifest_tracking_number
    attach_file('manifest[uploaded_file]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    expect(page).to have_content("Upload for manifest #{manifest_tracking_number} submitted successfully.")
  end

  scenario 'does not add file upload' do
    mock_authenticated_session
    manifest_tracking_number = '987654321abc'
    visit new_manifest_upload_path

    fill_in 'Manifest Tracking Number', with: manifest_tracking_number
    click_on 'Submit'

    expect(page).to have_content("File upload must be present.")
  end

  scenario 'upload after filling in form', elasticsearch: true do
    mock_authenticated_session
    manifest_tracking_number = '987654321abc'
    visit new_manifest_path

    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'
    click_on 'Upload'
    expect(page).not_to have_field('Manifest Tracking Number')

    attach_file('manifest[uploaded_file]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    expect(page).to have_content("Upload for manifest #{manifest_tracking_number} submitted successfully.")
  end
end

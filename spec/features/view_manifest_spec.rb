require 'rails_helper'

feature 'View manifest' do
  before :each do
    @current_session = mock_authenticated_session
  end

  scenario 'manifest has a file uploaded during creation', elasticsearch: true do
    manifest_tracking_number = '987654321abc'
    visit new_manifest_upload_path
    fill_in 'Manifest Tracking Number', with: manifest_tracking_number
    attach_file('manifest[uploaded_file]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    visit manifest_path(manifest_tracking_number)

    expect(page).to have_content('Download Scanned Image')
  end

  scenario 'manifest has file uploaded after creation', elasticsearch: true do
    manifest_tracking_number = '987654321abc'
    visit new_manifest_path

    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'
    click_on 'Upload'
    attach_file('manifest[uploaded_file]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    visit manifest_path(manifest_tracking_number)

    expect(page).to have_content('Download Scanned Image')
  end

  scenario 'manifest does not have a file upload' do
    manifest_tracking_number = '987654321abc'
    visit new_manifest_path
    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'

    visit manifest_path(manifest_tracking_number)

    expect(page).not_to have_content('Download Scanned Image')
    expect(page).to have_content('No scanned image available for this manifest.')
  end
end

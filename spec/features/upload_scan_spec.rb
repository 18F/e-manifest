require 'rails_helper'

feature 'Upload scan', elasticsearch: true do
  before(:each) do
    @current_session = mock_authenticated_session
  end

  scenario 'upload instead of filling out form' do
    manifest_tracking_number = '987654321abc'
    visit new_manifest_upload_path

    fill_in 'Manifest Tracking Number', with: manifest_tracking_number
    attach_file('manifest[uploaded_file]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    expect(page).to have_content("Upload for manifest #{manifest_tracking_number} submitted successfully.")
  end

  scenario 'upload after filling in form' do
    manifest_tracking_number = '987654321abc'
    visit new_manifest_path

    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'
    click_on 'Upload'
    attach_file('manifest[uploaded_file]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    expect(page).to have_content("Upload for manifest #{manifest_tracking_number} submitted successfully.")
  end
end

require 'rails_helper'

feature 'View manifest' do
  scenario 'manifest has a file uploaded during creation', elasticsearch: true do
    mock_authenticated_session
    manifest_tracking_number = '987654321abc'
    visit new_manifest_upload_path
    fill_in 'Manifest Tracking Number', with: manifest_tracking_number
    attach_file('manifest[uploaded_file]', Rails.root + "spec/support/fixtures/epa_form.pdf")
    click_on 'Submit'

    visit manifest_path(manifest_tracking_number)

    expect(page).to have_content('Download Scanned Image')
  end

  scenario 'manifest has file uploaded after creation', elasticsearch: true do
    mock_authenticated_session
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
    create_new_manifest
    expect(page).not_to have_content('Download Scanned Image')
  end

  scenario 'may not view a non-public manifest you do not have access to' do
    manifest_tracking_number = create_new_manifest

    user_session = login_as_different_user

    visit manifest_path(manifest_tracking_number)

    expect(page).to have_content('You do not have permission to view this record.')
    expect(page.status_code).to eq(403)
  end

  scenario 'anyone may view any public manifest' do
    public_era = Time.current - 100.days.ago.to_f
    Timecop.freeze(public_era)
    manifest_tracking_number = create_new_manifest
    Timecop.return

    user_session = login_as_different_user

    visit manifest_path(manifest_tracking_number)

    expect(page.status_code).to eq(200)

    user_session.expire

    visit manifest_path(manifest_tracking_number)

    expect(page.status_code).to eq(200)
  end

  def login_as_different_user
    user = create(:user)
    user_session = login_as(user)
    allow_any_instance_of(ApplicationController).to receive(:user_session).and_return(user_session)
    user_session
  end

  def create_new_manifest
    mock_authenticated_session
    manifest_tracking_number = '987654321abc'
    visit new_manifest_path
    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'

    visit manifest_path(manifest_tracking_number)
    expect(page).to have_content('No scanned image available for this manifest.')
    manifest_tracking_number
  end
end

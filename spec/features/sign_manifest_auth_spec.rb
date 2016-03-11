require 'rails_helper'

feature 'Sign manifest authentication' do
  scenario 'after submitting a manifest via form' do
    session = mock_user_signature_authorize_pass
    profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
    profile_syncer.run
    manifest = create(:manifest, user: session.user)

    visit new_manifest_sign_or_upload_path(manifest.uuid)
    click_on 'Sign'
    fill_in 'Username', with: 'valid_username'
    fill_in 'Password', with: 'correct_password'
    click_on 'Login'

    expect(page).to have_content("color?")
  end

  scenario 'with wrong username or password' do
    session = mock_user_signature_authn_fail
    profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
    profile_syncer.run
    manifest = create(:manifest, user: session.user)

    visit new_manifest_sign_or_upload_path(manifest.uuid)
    click_on 'Sign'
    fill_in 'Username', with: 'invalid_username'
    fill_in 'Password', with: 'incorrect_password'
    click_on 'Login'

    expect(page).to have_content('Bad user_id or password')
  end
end

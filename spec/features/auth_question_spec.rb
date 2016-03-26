require 'rails_helper'

feature 'Authentication question for signing manifest' do
  scenario 'submits correct answer to auth question' do
    session = mock_user_signature_authorize_pass
    profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
    profile_syncer.run

    manifest = create(:manifest, user: session.user)

    visit new_manifest_token_path(manifest.uuid)
    fill_in 'Username', with: 'correct_username'
    fill_in 'Password', with: 'correct_password'
    click_on 'Login'
    fill_in 'Answer', with: 'Test'
    click_on 'Sign manifest'

    expect(page).to have_content(
      "All done! Manifest #{manifest.tracking_number} has been signed and submitted."
    )
    expect(page).to have_content('Back to home')
    expect(page).to have_content('New manifest')
  end

  scenario 'submits correct answer to auth question, but lacks role' do
    session = mock_user_signature_authorize_pass

    manifest = create(:manifest, user: session.user)

    visit new_manifest_token_path(manifest.uuid)
    fill_in 'Username', with: 'correct_username'
    fill_in 'Password', with: 'correct_password'
    click_on 'Login'

    expect(page).to have_content(
      "You are not authorized to perform this action"
    )
  end

  scenario 'submits incorrect answer to auth question' do
    session = mock_user_signature_authorize_fail
    profile_syncer = UserProfileSyncer.new(session.user, mock_cdx_user_profile)
    profile_syncer.run

    manifest = create(:manifest, user: session.user)

    visit new_manifest_token_path(manifest.uuid)
    fill_in 'Username', with: 'correct_username'
    fill_in 'Password', with: 'correct_password'
    click_on 'Login'
    fill_in 'Answer', with: 'incorrect answer'
    click_on 'Sign manifest'

    expect(page).to have_content('Your answer does not match our records.')
    expect(page).to have_content("color?")
  end
end

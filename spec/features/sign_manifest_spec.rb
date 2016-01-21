require 'rails_helper'

feature 'Sign manifest' do
  scenario 'after submitting a manifest via form' do
    VCR.use_cassette('auth_success') do
      manifest = create(:manifest)
      question_from_fixture = 'What is the first and middle name of your oldest sibling?'

      visit new_manifest_sign_or_upload_path(manifest.uuid)
      click_on 'Sign'
      fill_in 'Username', with: 'valid_username'
      fill_in 'Password', with: 'correct_password'
      click_on 'Login'

      expect(page).to have_content(question_from_fixture)
    end
  end

  scenario 'submits correct answer to auth question' do
    VCR.use_cassette('sign_success') do
      manifest = create(:manifest)

      visit new_manifest_token_path(manifest.uuid)
      fill_in 'Username', with: 'correct_username'
      fill_in 'Password', with: 'correct_password'
      click_on 'Login'
      fill_in 'Answer', with: 'correct_answer'
      click_on 'Sign manifest'

      expect(page).to have_content(
        "All done! Manifest #{manifest.tracking_number} has been signed and submitted."
      )
      expect(page).to have_content('Back to home')
      expect(page).to have_content('New manifest')
    end
  end
end

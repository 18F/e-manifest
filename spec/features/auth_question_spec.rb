require 'rails_helper'

feature 'Authentication question for signing manifest' do
  scenario 'submits correct answer to auth question' do
    VCR.use_cassette('web_sign_success') do
      manifest = create(:manifest)

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
  end

  scenario 'submits incorrect answer to auth question' do
    VCR.use_cassette('web_sign_failure') do
      manifest = create(:manifest)
      question_from_fixture = 'What year and model (yyyy-name) was your first car?'

      visit new_manifest_token_path(manifest.uuid)
      fill_in 'Username', with: 'correct_username'
      fill_in 'Password', with: 'correct_password'
      click_on 'Login'
      fill_in 'Answer', with: 'incorrect answer'
      click_on 'Sign manifest'

      expect(page).to have_content('Your answer does not match our records.')
      expect(page).to have_content(question_from_fixture)
    end
  end
end

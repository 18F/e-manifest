require 'rails_helper'

feature 'Sign manifest authentication' do
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

  scenario 'with wrong username or password' do
    VCR.use_cassette('user_auth_failure') do
      manifest = create(:manifest)

      visit new_manifest_sign_or_upload_path(manifest.uuid)
      click_on 'Sign'
      fill_in 'Username', with: 'invalid_username'
      fill_in 'Password', with: 'incorrect_password'
      click_on 'Login'

      expect(page).to have_content('user INVALID_USERNAME does not exist')
    end
  end
end

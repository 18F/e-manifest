require 'rails_helper'

feature 'Sign manifest' do
  scenario 'after submitting a manifest via form' do
    manifest = create(:manifest)

    visit new_manifest_sign_or_upload_path(manifest)
    click_on 'Sign'

    expect(page).to have_field('Username')
    expect(page).to have_field('Password')
  end
end

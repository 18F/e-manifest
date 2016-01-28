require 'rails_helper'
require "queryparams"

describe 'manifests search', elasticsearch: true do
  context 'ui' do
    it 'supports structured query syntax' do
      user_session = mock_authenticated_session
      manifest = create(:manifest, :indexed, user: user_session.user)
      get "/manifests?aq[content.generator.name]=company"
      expect(response.body).to include(manifest.tracking_number.to_s)
    end

    it 'paginates' do
      user_session = mock_authenticated_session
      5.times { create(:manifest, :indexed, user: user_session.user) }
      get "/manifests?aq[content.generator.name]=company&page=2&size=2"
      expect(response.body).to include("Currently viewing 3-4 of 5 results")
    end
  end

  context 'authorization' do
    it 'shows only public manifests for anon users with no query' do
      user = create(:user)
      public_manifest = create(:manifest, :indexed, created_at: 100.days.ago, user: user)
      private_manifest = create(:manifest, :indexed, user: user)
      get "/manifests"
      expect(response.body).to include(public_manifest.tracking_number)
      expect(response.body).to_not include(private_manifest.tracking_number)
    end

    it 'allows anyone to search for public manifests' do
      user = create(:user)
      public_manifest = create(:manifest, :indexed, created_at: 100.days.ago, user: user)
      private_manifest = create(:manifest, :indexed, user: user)
      get "/manifests?q=company"
      expect(response.body).to include(public_manifest.tracking_number)
      expect(response.body).to_not include(private_manifest.tracking_number)
    end

    it 'shows public + private manifests for authenticated user' do
      user_session = mock_authenticated_session
      user = user_session.user
      public_manifest = create(:manifest, :indexed, created_at: 100.days.ago, user: user)
      private_manifest = create(:manifest, :indexed, user: user)
      get "/manifests"
      expect(response.body).to include(public_manifest.tracking_number)
      expect(response.body).to include(private_manifest.tracking_number)
    end

    it 'allows authenticated user to see public + any manifests they created' do
      user_session = mock_authenticated_session
      user = user_session.user
      public_manifest = create(:manifest, :indexed, created_at: 100.days.ago, user: user)
      private_manifest = create(:manifest, :indexed, user: user)
      get "/manifests?q=company"
      expect(response.body).to include(public_manifest.tracking_number)
      expect(response.body).to include(private_manifest.tracking_number)
    end
  end
end

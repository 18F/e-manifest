module UserAuthenticatorHelper
  def login_as(user, cdx_response = nil)
    UserSession.create(user, cdx_response)
  end

  def mock_authenticated_session
    user_session = mock_user_authenticator_pass
    allow_any_instance_of(ApplicationController).to receive(:user_session).and_return(user_session)
    user_session
  end

  def mock_user_authenticator_pass
    user = create(:user)
    user_org_role = create(:user_org_role, :tsdf_certifier, user: user)
    session = UserSession.create(user, { firstName: 'Jane', lastName: 'Doe' })
    cdx_signature = { token: SecureRandom.hex, question: { question_id: 123, question_text: 'color?' }, activity_id: SecureRandom.hex }
    allow_any_instance_of(UserAuthenticator).to receive(:authenticate).and_return(session)
    allow_any_instance_of(UserAuthenticator).to receive(:authorize_signature).and_return(session.merge_cdx(cdx_signature))
    allow_any_instance_of(UserAuthenticator).to receive(:session).and_return(session)
    allow_any_instance_of(UserAuthenticator).to receive(:error_message).and_return(nil)
    session
  end

  def mock_user_authenticator_fail
    allow_any_instance_of(UserAuthenticator).to receive(:authenticate).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:authorize_signature).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:error_message).and_return('Bad user_id or password')
  end

  def mock_user_authenticator_inactive
    allow_any_instance_of(UserAuthenticator).to receive(:authenticate).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:authorize_signature).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:error_message).and_return('Account is not yet active')
  end

  def mock_cdx_signature_response
    {
      transaction_id: 'mock_transaction_id',
      activity_id: 'mock_activity_id'
    }
  end

  def mock_user_signature_authorize_pass
    session = mock_authenticated_session
    allow_any_instance_of(ManifestSigner).to receive(:perform) do |manifest_signer|
      manifest_signer.update_manifest(mock_cdx_signature_response, manifest_signer.args)
      mock_cdx_signature_response
    end
    session
  end

  def mock_user_signature_authn_fail
    session = mock_authenticated_session
    allow_any_instance_of(UserAuthenticator).to receive(:authorize_signature).and_return(nil)
    allow_any_instance_of(UserAuthenticator).to receive(:error_message).and_return('Bad user_id or password')
    session
  end

  def mock_user_signature_authorize_fail
    session = mock_authenticated_session
    allow_any_instance_of(ManifestSigner).to receive(:perform).and_return({
      description: 'Your answer does not match our records.'
    })
    session
  end

  def mock_cdx_user_profile
    {
      organizations: {
        "EPA 2" => {
          org: {
            organizationId: "15404",
            organizationName: "EPA 2",
            primaryOrg: true,
            userOrganizationId: "86328",
            cdxEsaStatus: "None",
            city: "FAIRFAX",
            country: {code: "US", name: "UNITED STATES"},
            email: "someorg@example.com",
            mailingAddress1: "123 ENDLESS CIRCLE",
            state: {code: "VA", countryCode: "US", name: "Virginia", region: "3"},
            zip: 12345
          },
          roles: {
            "TSDF Certifier" => {
              dataflow: "eManifest",
              status: {
                code: "Active",
                description: "Active"
              },
              type: {
                code: "112110",
                description: "TSDF Certifier",
                status: "Active"
              },
              subject: "KS",
              userRoleId: "87638"
            }
          }
        }
      },
      user: {
        firstName: "Test",
        lastName: "Tester",
        status: "Valid",
        userId: "some_user",
      }
    }
  end

  def mock_cdx_profiles
    allow(UserProfileWorker).to receive(:perform_async).and_return(true)
    allow_any_instance_of(UserProfileBuilder).to receive(:run).and_return(mock_cdx_user_profile)
  end

  def mock_cdx_submit_response
    {
      transaction_id: 'mock_transaction_id',
      status: 'Received'
    }
  end

  def mock_cdx_submit_response_fails
    {
      transaction_id: 'mock_transaction_id',
      status: 'Failed'
    }
  end

  def mock_cdx_submit_authorize_pass
    session = mock_authenticated_session
    allow_any_instance_of(ManifestSubmitter).to receive(:perform) do
      mock_cdx_submit_response
    end
    session
  end

  def mock_cdx_submit_authorize_fails
    session = mock_authenticated_session
    allow_any_instance_of(ManifestSubmitter).to receive(:perform) do
      mock_cdx_submit_response_fails
    end
    session
  end

  def mock_cdx_submit_wrong_role
    session = mock_authenticated_session
    allow_any_instance_of(ManifestSubmitter).to receive(:perform) do
      raise Pundit::NotAuthorizedError
    end
    session
  end


end

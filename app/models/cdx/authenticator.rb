# NOTE: this class is a unique snow flake combining many requests and doing error logging
# not sure if it could/should be rolled into the LoggedRequest too
class CDX::Authenticator
  attr_reader :opts, :output_stream

  def initialize(opts, output_stream=$stdout)
    @opts = opts
    @output_stream = output_stream
  end

  def perform
    repackage_response
  rescue Savon::SOAPFault => e
    log_and_repackage_error(e)
  end

  private

  def signature_user
    @signature_user ||= CDX::User.new(opts, output_stream).authenticate
  end

  def security_token
    @security_token ||= CDX::System.new(output_stream).authenticate
  end

  def activity_id
    @activity_id ||= CDX::Activity.new({
      :token => security_token,
      :signature_user => signature_user,
      :dataflow_name => "eManifest",
      :activity_description => "development test",
      :role_name => "TSDF",
      :role_code => 112090
    }, output_stream).create
  end

  def question
    @question ||= CDX::Question.new({
      token: security_token,
      activity_id: activity_id,
      user: signature_user
    }, output_stream).get
  end

  def repackage_response
    {
      :token => security_token,
      :activity_id => activity_id,
      :question => question,
      :user_id => signature_user[:UserId]
    }
  end

  def log_and_repackage_error(error)
    CDX::HandleError.new(error, output_stream).perform
  end
end

class CDX::User < CDX::LoggedRequest
  private

  def request
    client.call(
      :authenticate, {
        message: {
          userId: opts[:user_id],
          password: opts[:password]
        }
      }
    )
  end

  def client
    CDX::Client::Auth
  end

  def log_response
    if color_log?
      output_stream.puts ANSI.blue{ response.hash.pretty_inspect }
    else
      output_stream.puts response.hash
    end
  end

  def repackage_response
    {
      UserId: user_data[:user_id],
      FirstName: user_data[:first_name],
      LastName: user_data[:last_name],
      MiddleInitial: user_data[:middle_initial]
    }
  end

  def user_data
    @user_data ||= response.hash[:envelope][:body][:authenticate_response][:user]
  end
end

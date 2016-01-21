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

  def user_data
    response.hash[:envelope][:body][:authenticate_response][:user]
  end

  def log_response
    output_stream.puts "---"
    output_stream.puts response.hash
    output_stream.puts "---"
  end

  def repackage_response
    {
      UserId: user_data[:user_id],
      FirstName: user_data[:first_name],
      LastName: user_data[:last_name],
      MiddleInitial: user_data[:middle_initial]
    }
  end
end

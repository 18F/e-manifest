module CDX
  class User
    attr_reader :output_stream, :opts

    def initialize(opts, output_stream=$stdout)
      @opts = opts
      @output_stream = output_stream
    end

    def authenticate
      puts opts
      puts authentication_response.hash
      repackage_response
    end

    private

    def puts(message)
      output_stream.puts(message)
    end

    def user_id
      opts['userId']
    end

    def password
      opts['password']
    end

    def user_data
      authentication_response.hash[:envelope][:body][:authenticate_response][:user]
    end

    def authentication_response
      @authentication_response ||= CDX::Client::Auth.call(:authenticate, {
        :message => {
          :userId => user_id, :password => password
        }
      })
    end

    def repackage_response
      {
        :UserId => user_data[:user_id],
        :FirstName => user_data[:first_name],
        :LastName => user_data[:last_name],
        :MiddleInitial => user_data[:middle_initial]
      }
    end
  end
end

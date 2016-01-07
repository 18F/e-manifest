if ENV['RACK_ENV'] != 'production'
  require 'dotenv'

  Dotenv.load
  dotenv_specific = File.expand_path("../../.env.#{ENV['RACK_ENV']}", __FILE__)

  if File.exist?(dotenv_specific)
    Dotenv.load dotenv_specific
  end
end

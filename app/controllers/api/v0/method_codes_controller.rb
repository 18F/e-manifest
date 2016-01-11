class Api::V0::MethodCodesController < ApplicationController
  def index
    content_type :json
    IO.read(File.dirname(__FILE__) + "/../public/api-data/method-codes.json")
  end
end

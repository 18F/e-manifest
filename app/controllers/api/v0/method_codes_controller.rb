class Api::V0::MethodCodesController < ApplicationController
  def index
    content_type :json
    IO.read("#{Rails.root}/db/data/method-codes.json")
  end
end

class Api::V0::MethodCodesController < ApiController
  def index
    render json: IO.read("#{Rails.public_path}/method-codes.json")
  end
end

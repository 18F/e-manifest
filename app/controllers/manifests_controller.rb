class ManifestsController < ApplicationController
  def new
  end

  def create
    @manifest = Manifest.new(content: manifest_params)

    if @manifest.save!
      tracking_number = manifest_params[:manifest_tracking_number]
      flash[:notice] = "Manifest #{tracking_number} submitted successfully."
      redirect_to new_manifest_path
    end
  end

  def index
    @manifests = Manifest.authorized_search({public: true}).records.to_a
  end

  private

  def manifest_params
    params.require(:generator).permit(
      :emergency_response_phone,
      :us_epa_id_number,
      :name,
      :manifest_tracking_number,
      :phone_number,
      mailing_address: [
        :address_1,
        :address_2,
        :city,
        :state,
        :zip_code,
      ],
    )
  end
end

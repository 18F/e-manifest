class ManifestsController < ApplicationController
  def new
  end

  def create
    @manifest = Manifest.new(content: manifest_params)

    if @manifest.save!
      tracking_number = manifest_params[:generator][:manifest_tracking_number]
      flash[:notice] = "Manifest #{tracking_number} submitted successfully."
      redirect_to new_manifest_sign_or_upload_path(@manifest)
    end
  end

  def index
    @manifests = Manifest.authorized_search({public: true}).records.to_a
  end

  def show
    @manifest = Manifest.find params[:id]
  end

  private

  def manifest_params
    params.require(:manifest).permit(
      generator: [
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
        ]
      ]
    )
  end
end

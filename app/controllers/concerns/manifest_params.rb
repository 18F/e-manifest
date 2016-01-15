module ManifestParams
  def manifest_params
    params.fetch(:manifest, {}).permit(
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

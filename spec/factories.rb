FactoryGirl.define do
  factory :manifest do
    content {{
      generator: {
        manifest_tracking_number: SecureRandom.uuid,
        name: "Company name",
      }
    }}
  end
end

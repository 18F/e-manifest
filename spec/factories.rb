FactoryGirl.define do
  factory :manifest do
    content {{
      generator: {
        manifest_tracking_number: SecureRandom.random_number(1_000_000_000)
        name: "Company name",
      }
    }}
  end
end

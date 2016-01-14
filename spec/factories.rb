FactoryGirl.define do
  factory :manifest do
    content {{
      generator: {
        manifest_tracking_number: "12345",
        name: "Company name",
      }
    }}

    after(:create) do |manifest, evaluator|
      manifest.reload # get uuid
    end
  end
end

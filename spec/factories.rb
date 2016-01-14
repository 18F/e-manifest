FactoryGirl.define do
  factory :manifest do
    activity_id SecureRandom.uuid
    document_id SecureRandom.uuid
    content {{
      generator: {
        manifest_tracking_number: SecureRandom.random_number(1_000_000_000),
        name: "Company name",
      }
    }}

    after(:create) do |manifest, evaluator|
      manifest.reload # get uuid
    end
  end
end

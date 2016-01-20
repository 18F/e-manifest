FactoryGirl.define do
  factory :manifest do
    content {{
      generator: {
        manifest_tracking_number: SecureRandom.random_number(1_000_000_000),
        name: "Company name",
      }
    }}

    after(:create) do |manifest, evaluator|
      manifest.reload # get uuid
    end

    trait :with_uploaded_file do
      content {{ uploaded_file: {
          file_name: 'test',
          content: '12345',
          content_type: 'application/pdf'
        }
      }}
    end

    trait :indexed do
      after(:create) do |manifest, evaluator|
        manifest.reindex
        Manifest.__elasticsearch__.refresh_index!
      end
    end
  end
end

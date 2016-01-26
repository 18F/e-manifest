include ExampleJsonHelper
FactoryGirl.define do
  factory :manifest do
    content {{
      generator: {
        manifest_tracking_number: random_tracking_number,
        name: "Company name",
      }
    }}
    association :user, factory: :user

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

  factory :user do
    cdx_user_id { SecureRandom.hex()[0..15] }
  end
end

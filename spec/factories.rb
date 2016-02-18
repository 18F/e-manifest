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

  factory :organization do
    sequence(:cdx_org_id) { |n| "org_#{n}" }
    cdx_org_name 'some org'
  end

  factory :role do
    sequence(:cdx_role_code) { |n| "role_code_#{n}" }
    cdx_role_name 'some role'

    trait :tsdf_certifier do
      cdx_role_name 'TSDF Certifier'
    end
  end

  factory :user_org_role do
    association :user, factory: :user
    association :organization, factory: :organization
    association :role, factory: :role
    sequence(:cdx_user_role_id)
    cdx_status 'Active'

    trait :tsdf_certifier do
      association :role, :tsdf_certifier
    end
  end
end

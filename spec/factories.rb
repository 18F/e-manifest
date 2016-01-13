FactoryGirl.define do
  factory :manifest do
    content {{
      generator: {
        manifest_tracking_number: "12345",
        name: "Company name",
      }
    }}
  end
end

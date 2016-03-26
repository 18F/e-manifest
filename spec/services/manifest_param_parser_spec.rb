require 'rails_helper'

describe ManifestParamParser do
  it 'filters out UI controls' do
   params = { 
      manifest: { 
        generator: { 
          site_address_same_as_mailing: true 
        },
        designated_facility: {
          shipment_has_discrepancy: false
        }
      },
      foo: 'bar'
    }

    parser = ManifestParamParser.new(params)

    parser.run

    expect(params).to eq({foo: 'bar', manifest: { generator: {}, designated_facility: {} }})
  end
end
    


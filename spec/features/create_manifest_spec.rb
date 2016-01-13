require 'rails_helper'

feature 'Create manifest' do
  scenario 'fills in tracking number' do
    manifest_tracking_number = '12345'
    visit new_manifest_path

    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    click_on 'Continue'

    expect(page).to have_content("Manifest #{manifest_tracking_number} submitted successfully.")
  end

  scenario 'fills in all fields' do
    manifest_tracking_number = '12345'
    visit new_manifest_path

    fill_in 'U.S. EPA ID Number (1)', with: 'test epa id number'
    fill_in 'Emergency Response Phone (3)', with: '555-555-5555'
    fill_in 'Manifest Tracking Number (4)', with: manifest_tracking_number
    fill_in 'Name (5)', with: 'Mailing name'
    fill_in 'Address 1 (5)', with: '123 Main Street'
    fill_in 'City (5)', with: 'Anytown'
    select 'California', from: 'State (5)'
    fill_in 'ZIP code (5)', with: '12345'
    fill_in 'Phone number (5)', with: '555-555-5555'

    # fill_in 'Company Name (6)', with: 'Transporter company name'
    # fill_in 'U.S. EPA ID Number (6)', with: 'Transporter EPA number'
    #
    # fill_in 'Name (8)', with: 'Designated facility name'
    # fill_in 'Address 1 (8)', with: '123 Designated Facility St.'
    # select 'ME', from: 'City (8)'
    # fill_in 'ZIP code (8)', with: '12345'
    # fill_in 'Phone number (8)', with: '555-555-5555'
    #
    # fill_in 'U.S. EPA ID Number (8)', with: 'Designated facility API number'
    # fill_in 'Proper Shipping Name', with: 'Proper shipping name'
    # fill_in 'Hazard Class', with: 'Hazard class value'
    # fill_in 'ID Number', with: '12345'
    # fill_in 'Packing Group', with: 'packing group'
    # fill_in 'Container Number (10)', with: 'container number'
    # select 'BA (Burlap, cloth, paper or plastic bags)', from: 'Container Type (10)'
    # fill_in 'Total Quantity (11)', with: 1
    # select 'G (Gallons)', from: 'Unit Wt./Vol. (12)'
    # fill_in 'Federal Waste Codes (13)', with: 'federal waste code'
    # fill_in 'State/Other Waste Codes (13)', with: 'state waste code'
    # fill_in 'Special Handling Instructions and Additional Information (14)', with: 'be careful'
    # fill_in 'PCB Description (14)', with: 'description'
    # fill_in 'Name of Generator/Offeror Signatory (15)', with: 'Jane Doe'
    # check 'Domestic Shipment'
    # fill_in 'Name of Signatory (17)', with: 'Jane Signatory'
    # fill_in 'Method Codes (19)', with: 'H040'
    # fill_in 'Name of Signatory (20)', with: 'Jane Designated Facility Signatory'
    click_on 'Continue'

    expect(page).to have_content("Manifest #{manifest_tracking_number} submitted successfully.")
  end
end

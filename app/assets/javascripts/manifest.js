$(document).ready(function () {
    $(".add-transporter").click(function (event) {
      event.preventDefault();
      addTransporter();
    });

    $(".remove-transporter").click(function (event) {
      event.preventDefault();
      removeItem(".tranporters", ".transporter");
    });

    $(".add-manifest-item").click(function (event) {
      event.preventDefault();
      addManifestItem();
    });

    $(".remove-manifest-item").click(function (event) {
      event.preventDefault();
      removeItem(".manifest-items", ".manifest-item");
    });

    $("#manifest_generator_site_address_same_as_mailing_false").click(function () {
        showFields(".site-address");
    });

    $("#manifest_designated_facility_shipment_has_discrepancy_true").click(function() {
      showFields(".discrepancy");
    });

    $("#manifest_international_true").click(function() {
      showFields(".international");
    });

    $("#manifest_generator_site_address_same_as_mailing_true").click(function () {
       hideFields(".site-address");
    });

    $("#manifest_designated_facility_shipment_has_discrepancy_false").click(function() {
      hideFields(".discrepancy");
    });

    $("#manifest_international_false").click(function() {
      hideFields(".international");
    });
});

function showFields(className) {
  $(className).show();
}

function hideFields(className) {
  $(className).hide();
}

function addTransporter() {
  var lastTransporterNumber = $(".transporters").find('input#transporter-number').last().data('number');
  var transporterNumber = lastTransporterNumber + 1;

  var transporter = '<div class="transporter"> ' +
    '<h4>Transporter ' + transporterNumber + '</h4> ' +
    '<label for="company_name">Company name (6)</label> ' +
    '<input type="text" ,="" name="manifest[transporters][][name]" data-number='+ transporterNumber +' id="transporter-number">' +
    '<label for="us_epa_id_number">U.S. EPA ID number (6)</label> ' +
    '<input type="text" ,="" name="manifest[transporters][][us_epa_id_number]"> ' +
    '<label for="signatory_name">Name of signatory (17)</label> ' +
    '<input type="text" ,="" name="manifest[transporters][][signatory][name]"> ' +
    '<label for="signatory_date">Date of signature (17)</label>' +
    '<input type="date" name="manifest[transporters][][signatory][date]" id="date">';

   $('.transporters').append(transporter);
}

function addManifestItem() {
  var lastManifestItemNumber = $(".manifest-items").find('.js-manifest-item').last().data('number');
  var manifestItemNumber = lastManifestItemNumber + 1;
  var newManifestItem = $('.manifest-item').last().clone();
  $('.manifest-items').append(newManifestItem);

  var newManifest = $(".manifest-item").last();
  replaceHeaderNumber(newManifest, lastManifestItemNumber, manifestItemNumber);
  replaceDataAttr(newManifest, manifestItemNumber);
}

function replaceHeaderNumber(newManifest, lastManifestItemNumber, manifestItemNumber) {
  var header = newManifest.find('h4');
  var newHeader = header.text().replace(lastManifestItemNumber, manifestItemNumber);
  header.text(newHeader);
}

function replaceDataAttr(newManifest, manifestItemNumber) {
  newManifest.find('#manifest_items_hazardous_material').last().attr('data-number', manifestItemNumber);
}

function removeItem(parentClass, childClass) {
  var items = $(parentClass).find(childClass);

  if (items.size() > 1) {
    items.last().remove();
  }
}

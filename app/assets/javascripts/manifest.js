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
        showAddressFields();
    });

    $("#manifest_generator_site_address_same_as_mailing_true").click(function () {
        hideAddressFields();
    });
});

function showAddressFields() {
  $(".site-address").show();
}

function hideAddressFields() {
  $(".site-address").hide();
}

function addTransporter() {
  var lastTransporterNumber = $(".transporters").find('input#transporter-number').last().data('number');
  var transporterNumber = lastTransporterNumber + 1;

  var transporter = '<div class="transporter"> ' +
    '<h4>Transporter ' + transporterNumber + '</h4> ' +
    '<label for="company_name">Company name (6)</label> ' +
    '<input type="text" ,="" name="manifest[transporters]['+ transporterNumber +'][name]" data-number='+ transporterNumber +' id="transporter-number">' +
    '<label for="us_epa_id_number">U.S. EPA ID number (6)</label> ' +
    '<input type="text" ,="" name="manifest[transporters]['+ transporterNumber +'][us_epa_id_number]"> ' +
    '<label for="signatory_name">Name of signatory (17)</label> ' +
    '<input type="text" ,="" name="manifest[transporters]['+ transporterNumber +'][signatory][name]"> ' +
    '<label for="signatory_date">Date of signature (17)</label>' +
    '<input type="date" name="manifest[transporters]['+ transporterNumber +'][signatory][date]" id="date">';

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
  replaceInputNameAttrs(newManifest, lastManifestItemNumber, manifestItemNumber);
}

function replaceHeaderNumber(newManifest, lastManifestItemNumber, manifestItemNumber) {
  var header = newManifest.find('h4');
  var newHeader = header.text().replace(lastManifestItemNumber, manifestItemNumber);
  header.text(newHeader);
}

function replaceDataAttr(newManifest, manifestItemNumber) {
  newManifest.find('#manifest_items_hazardous_material').last().attr('data-number', manifestItemNumber);
}

function replaceInputNameAttrs(newManifest, lastManifestItemNumber, manifestItemNumber) {
  var manifestItemInputs = newManifest.find('input, select');
  $(manifestItemInputs).each(function() {
    var name = $(this).attr('name');
    var newName = name.replace(lastManifestItemNumber, manifestItemNumber);
    $(this).attr('name', newName);
  });
}

function removeItem(parentClass, childClass) {
  var items = $(parentClass).find(childClass);

  if (items.size() > 1) {
    items.last().remove();
  }
}

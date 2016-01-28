$(document).ready(function () {
    $(".add-transporter").click(function (event) {
      event.preventDefault();
      addTransporter();
    });

    $(".remove-transporter").click(function (event) {
      event.preventDefault();
      removeTransporter();
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
  var transporterNumber = lastTransporterNumber + 1

  var transporter = '<div class="transporter"> ' +
    '<h4>Transporter ' + transporterNumber + '</h4> ' +
    '<label for="company_name">Company name (6)</label> ' +
    '<input type="text" ,="" name="manifest[transporters]['+ transporterNumber +'][name]" data-number='+ transporterNumber +' id="transporter-number">' +
    '<label for="us_epa_id_number">U.S. EPA ID number (6)</label> ' +
    '<input type="text" ,="" name="manifest[transporters]['+ transporterNumber +'][us_epa_id_number]"> ' +
    '<label for="signatory_name">Name of signatory (17)</label> ' +
    '<input type="text" ,="" name="manifest[transporters]['+ transporterNumber +'][signatory][name]"> ' +
    '<label for="signatory_date">Date of signature (17)</label>' +
    '<input type="date" name="manifest[transporters]['+ transporterNumber +'][signatory][date]" id="date">'

   $('.transporters').append(transporter);
}

function removeTransporter() {
  var transporters = $(".transporters").find('.transporter')

  if (transporters.size() > 1) {
    transporters.last().remove();
  }
}

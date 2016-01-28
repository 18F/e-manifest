$(document).ready(function () {
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

(function() {
  "use strict";

  var app = angular.module('app', []);

  app.controller('IndustryController', ['$scope', function($scope) {
    var self = $scope.industry = {};

    self.name = 'Hello World!!';
  }]);


  $(function() {
    $('#manifest_item_epa_waste_code_1').selectize({
      delimiter: ',',
      // persist: false,
      create: function(input) {
          return {
              value: input,
              text: input
          };
      }
    });
  });
})();

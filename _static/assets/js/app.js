(function() {
  "use strict";

  var app = angular.module('app', []);

  app.controller('IndustryController', ['$scope', function($scope) {
    var self = $scope.industry = {};

    self.name = 'Hello World!!';

    self.data = {};

    self.submit = function() {
      console.log(self.data);
    };
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

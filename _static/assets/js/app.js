(function() {
  "use strict";

  var app = angular.module('app', []);

  app.controller('IndustryController', ['$scope', function($scope) {
    var self = $scope.industry = {};

    self.name = 'Hello World!!';
  }]);
})();

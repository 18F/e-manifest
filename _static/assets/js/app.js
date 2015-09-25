(function() {
  "use strict";

  var app = angular.module('app', []);

  app.controller('IndustryController', ['$scope', '$http', function($scope, $http) {
    var self = $scope.industry = {};

    self.name = 'Hello World!!';

    self.data = {};

    self.submit = function() {
      $http.post('/api/manifest/submit/' + self.data.generator_manifest_tracking_number, self.data).then(function() {
        window.location.href = '/web/done.html';
      });
    };
  }]);

    var app2 = angular.module('app2', []);
    
    app2.controller('SearchController', function($scope, $http) {

        $scope.filter = function() {
            $http.get('/api/manifest/search').success(
                function(response) {$scope.results = response; 
            });
        };
  });
    
  $(function() {
    $('#manifest_item_epa_waste_code_1').selectize({
      delimiter: ',',
      create: true
    });
  });
})();

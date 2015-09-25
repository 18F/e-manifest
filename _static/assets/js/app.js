(function() {
  "use strict";

  var app = angular.module('app', []);

  // HACK: jekyll liquid {{}} tags conflict with angular, so changing to [[]] for now
  app.config(function($interpolateProvider) {
    $interpolateProvider.startSymbol('[[').endSymbol(']]');
  });

  app.controller('IndustryController', ['$scope', '$http', function($scope, $http) {
    var self = $scope.industry = {};

    self.name = 'Hello World!!';

    self.data = {};

    self.data.transporters = [{
      company_name: "",
      us_epa_id_number: "",
      signatory_name: "",
      transporter_signatory_date_month: "",
      transporter_signatory_date_day: "",
      transporter_signatory_date_year: ""
    }];

    self.addTransporter = function() {
      self.data.transporters.push({
        company_name: "",
        us_epa_id_number: "",
        signatory_name: "",
        transporter_signatory_date_month: "",
        transporter_signatory_date_day: "",
        transporter_signatory_date_year: ""
      });
    };

    self.removeTransporter = function(index) {
      self.data.transporters.splice(index, 1);
    };

    self.data.manifest_items = [{
      state_waste_codes: [{waste_code: ''}]
    }];

    self.addManifestItem = function() {
      self.data.manifest_items.push({
        state_waste_codes: [{waste_code: ''}]
      });
    };

    self.removeManifestItem = function(index) {
      self.data.manifest_items.splice(index, 1);
    };

    self.addStateWasteCode = function(index) {
      self.data.manifest_items[index].state_waste_codes.push({waste_code: ''});
    };

    self.removeStateWasteCode = function(parentIndex, index) {
      self.data.manifest_items[parentIndex].state_waste_codes.splice(index, 1);
    };

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

  if ($().selectize) {
    $(function() {
      $('.manifest_item_epa_waste_code').selectize({
        delimiter: ',',
        create: true
      });
    });
  }
})();

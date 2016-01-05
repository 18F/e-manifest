(function() {
  "use strict";

  var app = angular.module('app', ['ngRoute']);

  // HACK: jekyll liquid {{}} tags conflict with angular, so changing to [[]] for now
  app.config(function($interpolateProvider) {
    $interpolateProvider.startSymbol('[[').endSymbol(']]');
  });

  app.controller('IndustryController', ['$scope', '$http', '$timeout', function($scope, $http, $timeout) {
    var self = $scope.industry = {};
    var uiData = $scope.uiData = {};

    self.name = 'Hello World!!';

    self.data = {};

    self.data.transporters = [{ }];

    self.addTransporter = function() {
      self.data.transporters.push({ });
    };

    self.removeTransporter = function(index) {
      self.data.transporters.splice(index, 1);
    };

    self.data.manifest_items = [{ }];

    uiData = [{
      epa_waste_codes: "",
      state_waste_codes: "",
      hazard_classes: ""
    }];

    self.addManifestItem = function() {
      var nextManifestIndex = self.data.manifest_items.length;
      self.data.manifest_items.push({ });

      uiData.push({
        epa_waste_codes: "",
        state_waste_codes: "",
        hazard_classes: ""
      });

      deferSelectize({
        selector: '.manifest_item_epa_waste_code_' + nextManifestIndex,
        setter: function(wasteCodes) {
          self.data.manifest_items[nextManifestIndex].epa_waste_codes = wasteCodes;
        }
      });

      deferSelectize({
        selector: '.manifest_item_state_waste_code_' + nextManifestIndex,
        setter: function(wasteCodes) {
          self.data.manifest_items[nextManifestIndex].state_waste_codes = wasteCodes;
        }
      });

      deferSelectize({
        selector: '.manifest_item_proper_hazard_class_' + nextManifestIndex,
        setter: function(hazardClasses) {
          self.data.manifest_items[nextManifestIndex].hazard_classes = hazardClasses;
        }
      });
    };

    self.removeManifestItem = function(index) {
      self.data.manifest_items.splice(index, 1);
      uiData.splice(index, 1);
    };

    self.submit = function() {
      $http.post('/api/0.1/manifest/submit/' + self.data.generator.manifest_tracking_number, self.data)
           .then(function successCallback(response) {
             var manifestUri = response.headers("Location");
             var status = response.status;
             var emanifestId = manifestUri.split("/").pop();
             if (status === "201") {
               console.log("manifest created and located here: " + manifestUri);
             }
        window.location.href = '/web/sign.html#!/?id=' + emanifestId + '&manifestTrackingNumber=' + self.data.generator.manifest_tracking_number;
      });
    };

    $scope.formatCanonicalPhone = function(isValid, phoneNumber) {
      if (!isValid) {
        return phoneNumber;
      }

      var phoneDigits = phoneNumber.replace(/\D/g, "");
      var containsPlusOnePrefix = (phoneDigits.length === 11);

      if (containsPlusOnePrefix) {
        phoneDigits = phoneDigits.substr(1);
      }

      var canonicalPhone = phoneDigits.replace(/(\d{3})(\d{3})(\d{4})/, "$1-$2-$3");
      return canonicalPhone;
    };

    $scope.phonePattern = /^(?:(?:\+?1\s*(?:[.-]\s*)?)?\(?\s*(?:(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*\)?\s*(?:[.-]\s*)?)([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})$/;

    var deferSelectize = function(options) {
      $timeout(function() {
        selectize(options);
      }, 0);
    };

    var selectize = function(options) {
      if ($().selectize) {
        var selector = options.selector;
        var setter = options.setter;
        var load = options.load;
        var valueField = options.valueField;
        var labelField = options.labelField;
        var searchField = options.searchField;
        var preload = load ? true : false;

        $(function() {
          $(selector).selectize({
            plugins: ['remove_button'],
            delimiter: ',',
            create: true,
            load: load,
            valueField: valueField,
            labelField: labelField,
            searchField: searchField,
            preload: preload,
            onBlur: function() {
              var value = this.$input.val();
              var modelValue = value.split(",");
              setter.call(this, modelValue);
            }
          });
        });
      }
    };

    selectize({
      selector: '.manifest_item_epa_waste_code_0',
      setter: function(wasteCodes) {
        self.data.manifest_items[0].epa_waste_codes = wasteCodes;
      }
    });

    selectize({
      selector: '.manifest_item_state_waste_code_0',
      setter: function(wasteCodes) {
        self.data.manifest_items[0].state_waste_codes = wasteCodes;
      }
    });

    deferSelectize({
      selector: '.manifest_item_proper_hazard_class_0',
      setter: function(hazardClasses) {
        self.data.manifest_items[0].hazard_classes = hazardClasses;
      }
    });

    selectize({
      selector: '.report_management_method_codes',
      setter: function(methodCodes) {
        self.data.report_management_method_codes = methodCodes;
      },
      load: function(value, callback) {
        $.ajax({
					url: '/api/0.1/method_code',
					type: 'GET',
					error: function() {
						callback();
					},
					success: function(response) {
						callback(response);
					}
				});
      },
      valueField: "code",
      labelField: "code",
      searchField: "code"
    });


  }]);

  app.controller('SearchController', function($scope, $http, $location) {
    var self = $scope.search = {};
    $scope.data = {};
    $scope.results = [];
    $scope.sorted = { field: "_score", descending: true };

    $scope.searchAPIparams = function() {
      var locParams = $location.search();
      if (locParams["sort[]"]) {
        var sortPair = (typeof locParams == "array" ? locParams["sort[]"][0] : locParams["sort[]"]).split(':');
        $scope.sorted.field = sortPair[0];
        if (sortPair[1]) {
          $scope.sorted.descending = sortPair[1] == "desc";
        }
        else if ($scope.sorted.field == "_score") {
          $scope.sorted.descending = true;
        }
        else {
          $scope.sorted.descending = false;
        }
      }
      return jQuery.param(locParams);
    }

    // $location requires the # in the url
    if (!window.location.href.match(/#\?/) && window.location.href.match(/\?/)) {
      window.location = window.location.href.replace(/\?/, "#?");
    }

    $scope.parseResults = function(response) {
      var hits = [];
      jQuery.each(response.hits, function(i, hit) {
        var item = hit._source;

        //fix for my local env.
        if (typeof item.content == "string") {
          item.content = item.content.replace(/[=]/g, ":");
          item.content = item.content.replace(/[>]/g, "");
          item.content = jQuery.parseJSON(item.content);
        }   
  
        var updatedAtString = item.updated_at;
        if (updatedAtString) {
          item.formatted_date = new Date(updatedAtString).toLocaleDateString();
        }   
        hits.push(item);
      }); 
      $scope.total = response.total;
      $scope.results = hits;
    }

    $scope.fetchResults = function() {
      $http.get('/api/0.1/manifest/search?'+$scope.searchAPIparams()).success(function(response) {
        $scope.parseResults(response);
      });
    }

    $scope.sortBy = function(fieldName) {
      if ($scope.sorted.field == fieldName) {
        $scope.sorted.descending = !$scope.sorted.descending;
      }
      else {
        $scope.sorted.field = fieldName;
        $scope.sorted.descending = fieldName == "_score" ? true : false;
      }
      $location.search("sort[]", [$scope.sorted.field, ($scope.sorted.descending ? "desc" : "asc")].join(':'));
      $scope.fetchResults();
    }

    $scope.manifestDetail = function(data) {
      window.location.href = '/web/manifest-detail.html#?id='+data.id;
    }

    // fire the initial results if we have params
    if ($location.search()) {
      $scope.initialParams = $location.search();
      $scope.fetchResults();
    }
  });

  app.controller('ManifestDetailController', function($scope, $http, $location) {

    var id = $location.search().id;
    $http.get('/api/0.1/manifest/id/'+id).success( function(response) {
      //fix for my local env.
      if (typeof response.content == "string") {
        response.content = response.content.replace(/[=]/g, ":");
        response.content = response.content.replace(/[>]/g, "");
        response.content = jQuery.parseJSON(response.content);
      }
      $scope.data = response;
    });
  });

  app.controller('SignController', function($scope, $http, $location) {
    $scope.state = 'login';

    $scope.authenticate = function() {
      self.data = {
        user_id: $("#user_id").val(),
        password: $("#password").val()
      };

      $http.post('/api/0.1/user/authenticate', self.data).then(
        function successCallback(response) {
          $scope.authenticateResponse = response.data;
          $scope.state = 'answer';
        });
    };

    $scope.signManifest = function() {
      var authenticateResponse = $scope.authenticateResponse;
      var emanifestId = $location.search().id;
      var manifestTrackingNumber = $location.search().manifestTrackingNumber;
      $scope.manifestTrackingNumber = manifestTrackingNumber;

      self.data = {
        "token": authenticateResponse.token,
        "activity_id": authenticateResponse.activity_id,
        "user_id": authenticateResponse.user_id,
        "question_id": authenticateResponse.question.question_id,
        "answer": $("#answer").val(),
        "id": emanifestId
      };

      $http.post('/api/0.1/manifest/sign', self.data).then(
        function successCallback(response) {
          $scope.state = 'confirmation';
        });
    };

  }).directive("signLogin", function() {
    return {
      templateUrl: "sign-login.html",
      restrict: "E"
    };
  }).directive("signAnswer", function() {
    return {
      templateUrl: "sign-answer.html",
      restrict: "E"
    };
  }).directive("signConfirmation", function() {
    return {
      templateUrl: "sign-confirmation.html",
      restrict: "E"
    };
  });

}

)();

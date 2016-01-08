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
             window.location.href = '/web/sign-or-upload.html#!/?id=' + emanifestId + '&manifestTrackingNumber=' + self.data.generator.manifest_tracking_number;
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

  app.controller('SignOrUploadController', function($scope, $location) {
    var search = $location.search();
    $scope.data = {};

    Object.keys(search).map(function(k) {
      $scope.data[k] = search[k];
    });

    function searchQueryString (data) {
      var keys = Object.keys(data);
      var s = keys.map(function(k) {
        return [k, data[k]].join('=');
      }).join('&');

      return s;
    }

    $scope.sign = function () {
      window.location.href = '/web/sign.html?' + searchQueryString($scope.data);
    };

    $scope.upload = function () {
      window.location.href = '/web/bulk-upload.html?' + searchQueryString($scope.data);
    };

  });

  app.controller('SearchController', function($scope, $http) {
    var self = $scope.search = {};
    $scope.data = {};
    $scope.filtered = {};
    $scope.results = {};

    $http.get('/api/0.1/manifest/search').success(function(response) {
      for(var i = 0; i < response.length; i++) {
        var item = response[i];

        //fix for my local env.
        if(typeof item.content == "string") {
          item.content = item.content.replace(/[=]/g, ":");
          item.content = item.content.replace(/[>]/g, "");
          item.content = jQuery.parseJSON(item.content);
        }

        var updatedAtString = response[i].updated_at;
        if (updatedAtString) {
          response[i].formatted_date = new Date(updatedAtString).toLocaleDateString();
        }
      }

      $scope.results = response;
      $scope.filtered = response;
    });

    $scope.filter = function() {
      var gname, tname, items;
      if ($scope.data.generator) {
        gname = $scope.data.generator.name;
      }
      tname = $scope.data.tsdf_name;
      items = new Array();

      for(var i = 0; i < $scope.results.length; i++) {
        var isAdded = false;
        var item = $scope.results[i];

        if(gname != undefined && item.content.generator && gname == item.content.generator.name)
        {
            items.push(item);
            isAdded = true;
        }

        if(isAdded == false && tname != undefined && item.content.designated_facility && tname == item.content.designated_facility.name)
        {
           items.push(item);
        }
      }

      $scope.filtered = items;
    };

    $scope.manifestDetail = function(data) {
      window.location.href = '/web/manifest-detail.html?id='+data.id;
    }
  });

  app.controller('ManifestDetailController', ['$scope','$http',function($scope, $http) {

      function getQueryParams(qs) {
          qs = qs.split('+').join(' ');

          var params = {},
              tokens,
              re = /[?&]?([^=]+)=([^&]*)/g;

          while (tokens = re.exec(qs)) {
              params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
          }

          return params;
      }

      var id = getQueryParams(document.location.search).id;;
      $http.get('/api/0.1/manifest/id/'+id).success(
          function(response) {
              //fix for my local env.
              if(typeof response.content == "string")
              {
                  response.content = response.content.replace(/[=]/g, ":");
                  response.content = response.content.replace(/[>]/g, "");
                  response.content = jQuery.parseJSON(response.content);
              }
            $scope.data = response;
          });
  }]);

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

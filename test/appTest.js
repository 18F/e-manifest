var assert = chai.assert;

describe("SignController", function() {

  beforeEach(module("app"));

  var $controller;

  beforeEach(inject(function(_$controller_){
    // Voodoo to get access to Angular controller instantiation service.
    $controller = _$controller_;
  }));

  it("has initial state of 'login'", function() {
    var $scope = {};
    
    $controller("SignController", { $scope: $scope });

    assert.equal("login", $scope["state"]);
  });
  
});


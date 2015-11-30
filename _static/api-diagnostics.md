---
title: eManifest API Diagnostics | US EPA
header_title: eManifest API Diagnostics
permalink: /api-diagnostics/
---

# Submit Manifest

**POST** /api/0.1/manifest/submit/12345
Data: `{ "manifest": 12345 }`
<a href="javascript:submitManifest();">Run »</a>

Response:
<pre><code id="submit-manifest-response"></code></pre>

# Search for Manifests

**GET** /api/0.1/manifest/search**?city=madison&state=wi**
<a href="javascript:searchManifest();">Run »</a>

Response:
<pre><code id="search-manifest-response"></code></pre>

# Get a Manifest by eManifest ID

**GET** /api/0.1/manifest/id/*
<label for="manifest_id">eManifest ID: <input id="manifest_id"></label>
<a href="javascript:getManifest();">Run »</a>

Response:
<pre><code id="get-manifest-response"></code></pre>

# Get a Manifest by Manifest Tracking Number

**GET** /api/0.1/manifest/*
<label for="get_manifest_tracking_number">Manifest Tracking Number: <input id="get_manifest_tracking_number"></label>
<a href="javascript:getManifestByTrackingNumber();">Run »</a>

Response:
<pre><code id="get-manifest-tracking-number-response"></code></pre>

# Update a Manifest by eManifest ID

**PATCH** /api/0.1/manifest/id/*
<label for="update_manifest_id">eManifest ID: <input id="update_manifest_id"></label>
<label for="update_manifest_generator_name">Generator Name: <input id="update_manifest_generator_name"></label>
Data: `[{ "op": "replace", "path": "/generator/name", "value": "name entered above" }]`
<a href="javascript:updateManifest();">Run »</a>

Response:
<pre><code id="update-manifest-response"></code></pre>

# Update a Manifest by Manifest Tracking Number

**PATCH** /api/0.1/manifest/*
<label for="update_manifest_tracking_number">Manifest Tracking Number: <input id="update_manifest_tracking_number"></label>
<label for="update_manifest_tracking_number_generator_name">Generator Name: <input id="update_manifest_tracking_number_generator_name"></label>
Data: `[{ "op": "replace", "path": "/generator/name", "value": "name entered above" }]`
<a href="javascript:updateManifestByTrackingNumber();">Run »</a>

Response:
<pre><code id="update-manifest-tracking-number-response"></code></pre>

# Reset Database

Warning: All data will be deleted and reset!
<a href="javascript:resetDatabase();">Reset Database »</a>

# Authenticate User

**POST** /api/0.1/user/authenticate
Data: `{ "user_id": username, "password": password  }`
<label for="username">CDX username: <input id="username"></label>
<label for="password">CDX password: <input type="password" id="password"></label>
<a href="javascript:authenticateUser();">Run »</a>

Response:
<pre><code id="authenticate-user-response"></code></pre>

# Sign Manifest by eManifest ID

**POST** /api/0.1/manifest/sign
(data from authenticate user request + answer to the question)
Data: `{ "token": token, "activity_id": activity id, "user_id": user id,
"question_id": question id, "answer": answer, "id": eManifest id }`
<label for="sign_manifest_id">eManifest ID: <input id="sign_manifest_id"></label>
<label for="answer">Answer to CDX question: <input type="password" id="answer"></label>
<label for="token">CROMERR token: <input id="token"></label>
<label for="activity_id">CROMERR activity id: <input id="activity_id"></label>
<label for="user_id">CDX user id: <input id="user_id"></label>
<label for="question_id">CDX question id: <input id="question_id"></label>
<a href="javascript:signManifest();">Run »</a>

Response:
<pre><code id="sign-manifest-response"></code></pre>

# Sign Manifest by Manifest Tracking Number

**POST** /api/0.1/manifest/signByTrackingNumber
(data from authenticate user request + answer to the question)
Data: `{ "token": token, "activity_id": activity id, "user_id": user id,
"question_id": question id, "answer": answer, "manifest_tracking_number": manifest_tracking_number }`
<label for="sign_by_manifest_tracking_number">Manifest Tracking Number: <input id="sign_by_manifest_tracking_number"></label>
<label for="answer_by_manifest_tracking_number">Answer to CDX question: <input type="password" id="answer_by_manifest_tracking_number"></label>
<label for="token_by_manifest_tracking_number">CROMERR token: <input id="token_by_manifest_tracking_number"></label>
<label for="activity_id_by_manifest_tracking_number">CROMERR activity id: <input id="activity_id_by_manifest_tracking_number"></label>
<label for="user_id_by_manifest_tracking_number">CDX user id: <input id="user_id_by_manifest_tracking_number"></label>
<label for="question_id_by_manifest_tracking_number">CDX question id: <input id="question_id_by_manifest_tracking_number"></label>
<a href="javascript:signManifestByTrackingNumber();">Run »</a>

Response:
<pre><code id="sign-manifest-by-tracking-number-response"></code></pre>

# Get Management Method Codes

**GET** /api/0.1/method_code
<a href="javascript:getMethodCodes();">Run »</a>

Response:
<pre><code id="get-method-codes-response"></code></pre>


<script>
  
  function prettyJson(data) {
    return JSON.stringify(data, null, 2);
  }

  var showSuccessfulResponse = function(nodeSelector) {
    return function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + prettyJson(data);
      $(nodeSelector).text(res);
    };
  };

  var showFailureResponse = function(nodeSelector) {
    return function(xhr, textStatus, error) {
      var res = xhr.status + " " + xhr.statusText;
      $(nodeSelector).text(res);
    };
  };
  
  function submitManifest() {
    $.ajax({
      type: 'POST',
      url: '/api/0.1/manifest/submit/12345',
      data: '{ "manifest": 12345 }'
    })
    .done(showSuccessfulResponse('#submit-manifest-response'))
    .fail(showFailureResponse('#submit-manifest-response'));
  };
  
  function searchManifest() {
    $.ajax({
      type: 'GET',
      url: '/api/0.1/manifest/search?city=madison&state=wi',
    })
    .done(showSuccessfulResponse('#search-manifest-response'))
    .fail(showFailureResponse('#search-manifest-response'));
  };
  
  function resetDatabase() {
    /*$.get('/reset', function(data) {
      alert(data);
    });*/
  };

  function authenticateUser() {
    var username = $("#username").val();
    var password = $("#password").val();
    
    $.ajax({
      type: 'POST',
      url: '/api/0.1/user/authenticate',
      contentType: 'application/json',
      data: JSON.stringify({ "user_id": username, "password": password })
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + prettyJson(data);
      $('#authenticate-user-response').text(res);
      $('#user_id').val(data["user_id"]);
      $('#token').val(data["token"]);
      $('#activity_id').val(data["activity_id"]);
      $('#question_id').val(data["question"]["question_id"]);
      $('#answer').val("");
      $('#user_id_by_manifest_tracking_number').val(data["user_id"]);
      $('#token_by_manifest_tracking_number').val(data["token"]);
      $('#activity_id_by_manifest_tracking_number').val(data["activity_id"]);
      $('#question_id_by_manifest_tracking_number').val(data["question"]["question_id"]);
      $('#answer_by_manifest_tracking_number').val("");
    })
    .fail(showFailureResponse('#authenticate-user-response'));
  };

  function signManifest() {
    var manifest_id = $("#sign_manifest_id").val();
    var token = $("#token").val();
    var activity_id = $("#activity_id").val();
    var user_id = $("#user_id").val();
    var question_id = $("#question_id").val();
    var answer = $("#answer").val();
    
    $.ajax({
      type: 'POST',
      url: '/api/0.1/manifest/sign',
      contentType: 'application/json',
      data: JSON.stringify({ "id": manifest_id, "token": token,
            "activity_id": activity_id, "user_id": user_id,
            "question_id": question_id, "answer": answer })
    })
    .done(showSuccessfulResponse('#sign-manifest-response'))
    .fail(showFailureResponse('#sign-manifest-response'));
  };
  
  function signManifestByTrackingNumber() {
    var manifest_tracking_number = $("#sign_by_manifest_tracking_number").val();
    var token = $("#token_by_manifest_tracking_number").val();
    var activity_id = $("#activity_id_by_manifest_tracking_number").val();
    var user_id = $("#user_id_by_manifest_tracking_number").val();
    var question_id = $("#question_id_by_manifest_tracking_number").val();
    var answer = $("#answer_by_manifest_tracking_number").val();
    
    $.ajax({
      type: 'POST',
      url: '/api/0.1/manifest/signByTrackingNumber',
      contentType: 'application/json',
      data: JSON.stringify({ "manifest_tracking_number": manifest_tracking_number, "token": token,
            "activity_id": activity_id, "user_id": user_id,
            "question_id": question_id, "answer": answer })
    })
    .done(showSuccessfulResponse('#sign-manifest-by-tracking-number-response'))
    .fail(showFailureResponse('#sign-manifest-by-tracking-number-response'));
  };
  
  function getManifest() {
    var manifest_id = $("#manifest_id").val();
    
    $.ajax({
      type: 'GET',
      url: '/api/0.1/manifest/id/'+manifest_id
    })
    .done(showSuccessfulResponse('#get-manifest-response'))
    .fail(showFailureResponse('#get-manifest-response'));
  };
  
  function getManifestByTrackingNumber() {
    var manifest_tracking_number = $("#get_manifest_tracking_number").val();
    
    $.ajax({
      type: 'GET',
      url: '/api/0.1/manifest/'+manifest_tracking_number
    })
    .done(showSuccessfulResponse('#get-manifest-tracking-number-response'))
    .fail(showFailureResponse('#get-manifest-tracking-number-response'));
  };
  
  function updateManifest() {
    var manifest_id = $("#update_manifest_id").val();
    var generator_name = $("#update_manifest_generator_name").val();
    $.ajax({
      type: 'PATCH',
      url: '/api/0.1/manifest/id/'+manifest_id,
      data: JSON.stringify([{ "op": "replace", "path": "/generator/name", "value": generator_name }])
    })
    .done(showSuccessfulResponse('#update-manifest-response'))
    .fail(showFailureResponse('#update-manifest-response'));
  };
  
  function updateManifestByTrackingNumber() {
    var manifest_tracking_number = $("#update_manifest_tracking_number").val();
    var generator_name = $("#update_manifest_tracking_number_generator_name").val();
    $.ajax({
      type: 'PATCH',
      url: '/api/0.1/manifest/'+manifest_tracking_number,
      data: JSON.stringify([{ "op": "replace", "path": "/generator/name", "value": generator_name }])
    })
    .done(showSuccessfulResponse('#update-manifest-tracking-number-response'))
    .fail(showFailureResponse('#update-manifest-tracking-number-response'));
  };
  
  function getMethodCodes() {
    $.ajax({
      type: 'GET',
      url: '/api/0.1/method_code'
    })
    .done(showSuccessfulResponse('#get-method-codes-response'))
    .fail(showFailureResponse('#get-method-codes-response'));
  };

</script>

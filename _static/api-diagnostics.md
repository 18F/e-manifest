---
title: API Diagnostics
permalink: /api-diagnostics/
---

# Submit Manifest

**POST** /api/manifest/submit/12345
Data: `{ "manifest": 12345 }`
<a href="javascript:submitManifest();">Run »</a>

Response:
<pre><code id="submit-manifest-response"></code></pre>

# Search for Manifests

**GET** /api/manifest/search**?city=madison&state=wi**
<a href="javascript:searchManifest();">Run »</a>

Response:
<pre><code id="search-manifest-response"></code></pre>

# Get for Manifest

**GET** /api/manifest/id/*
<label for="username">eManifest ID: <input id="manifest_id"></label>
<a href="javascript:getManifest();">Run »</a>

Response:
<pre><code id="get-manifest-response"></code></pre>


# Reset Database

Warning: All data will be deleted and reset!
<a href="javascript:resetDatabase();">Reset Database »</a>

# Authenticate User

**POST** /api/user/authenticate
Data: `{ "userId": username, "password": password  }`
<label for="username">CROMERR username: <input id="username"></label>
<label for="password">CROMERR password: <input type="password" id="password"></label>
<a href="javascript:authenticateUser();">Run »</a>

Response:
<pre><code id="authenticate-user-response"></code></pre>

# Sign Manifest

**POST** /api/manifest/sign
(data from authenticate user request + answer to the question)
Data: `{ "token": token, "activityId": activity id, "userId": user id,
"questionId": question id, "answer": answer, "id": e-manifest id }`
<label for="manifestId">manifest id: <input id="manifestId"></label>
<label for="answer">Answer to CROMERR question: <input type="password" id="answer"></label>
<label for="token">CROMERR token: <input id="token"></label>
<label for="activityId">CROMERR activity id: <input id="activityId"></label>
<label for="userId">CROMERR user id: <input id="userId"></label>
<label for="questionId">CROMERR question id: <input id="questionId"></label>
<a href="javascript:signManifest();">Run »</a>

Response:
<pre><code id="sign-manifest-response"></code></pre>

<script>
  
  function prettyJson(data) {
    return JSON.stringify(data, null, 2);
  }
  
  function submitManifest() {
    $.ajax({
      type: 'POST',
      url: '/api/manifest/submit/12345',
      data: '{ "manifest": 12345 }'
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + data;
      $('#submit-manifest-response').append(res);
    });
  }
  
  function searchManifest() {
    $.ajax({
      type: 'GET',
      url: '/api/manifest/search?city=madison&state=wi',
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + prettyJson(data);
      $('#search-manifest-response').text(res);
    });
  }
  
  function resetDatabase() {
    /*$.get('/reset', function(data) {
      alert(data);
    });*/
  }

  function authenticateUser() {
    var username = $("#username").val();
    var password = $("#password").val();
    
    $.ajax({
      type: 'POST',
      url: '/api/user/authenticate',
      contentType: 'application/json',
      data: JSON.stringify({ "userId": username, "password": password })
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + prettyJson(data);
      $('#authenticate-user-response').text(res);
      $('#userId').val(data["userId"]);
      $('#token').val(data["token"]);
      $('#activityId').val(data["activityId"]);
      $('#questionId').val(data["question"]["questionId"]);
      $('#answer').val("");
    });
  }

  function signManifest() {
    var manifestId = $("#manifestId").val();
    var token = $("#token").val();
    var activityId = $("#activityId").val();
    var userId = $("#userId").val();
    var questionId = $("#questionId").val();
    var answer = $("#answer").val();
    
    $.ajax({
      type: 'POST',
      url: '/api/manifest/sign',
      contentType: 'application/json',
      data: JSON.stringify({ "id": manifestId, "token": token,
            "activityId": activityId, "userId": userId,
            "questionId": questionId, "answer": answer })
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + prettyJson(data);
      $('#sign-manifest-response').text(res);
    });
  }
  
  function getManifest() {
    var manifestId = $("#manifest_id").val();
    
    $.ajax({
      type: 'GET',
      url: '/api/manifest/id/'+manifestId,
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
          res += "\n" + prettyJson(data);
      $('#get-manifest-response').text(res);
    });
  }

</script>

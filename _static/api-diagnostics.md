---
title: API Diagnostics
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

# Get for Manifest

**GET** /api/0.1/manifest/id/*
<label for="username">eManifest ID: <input id="manifest_id"></label>
<a href="javascript:getManifest();">Run »</a>

Response:
<pre><code id="get-manifest-response"></code></pre>


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

# Sign Manifest

**POST** /api/0.1/manifest/sign
(data from authenticate user request + answer to the question)
Data: `{ "token": token, "activity_id": activity id, "user_id": user id,
"question_id": question id, "answer": answer, "id": eManifest id }`
<label for="manifest_id">eManifest ID: <input id="manifest_id"></label>
<label for="answer">Answer to CDX question: <input type="password" id="answer"></label>
<label for="token">CROMERR token: <input id="token"></label>
<label for="activity_id">CROMERR activity id: <input id="activity_id"></label>
<label for="user_id">CDX user id: <input id="user_id"></label>
<label for="question_id">CDX question id: <input id="question_id"></label>
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
      url: '/api/0.1/manifest/submit/12345',
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
      url: '/api/0.1/manifest/search?city=madison&state=wi',
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
    });
  }

  function signManifest() {
    var manifest_id = $("#manifest_id").val();
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
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + prettyJson(data);
      $('#sign-manifest-response').text(res);
    });
  }
  
  function getManifest() {
    var manifest_id = $("#manifest_id").val();
    
    $.ajax({
      type: 'GET',
      url: '/api/0.1/manifest/id/'+manifest_id,
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
          res += "\n" + prettyJson(data);
      $('#get-manifest-response').text(res);
    });
  }

</script>

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

# Reset Database

Warning: All data will be deleted and reset!
<a href="javascript:resetDatabase();">Reset Database »</a>

# Authenticate User

**POST** /api/user/authenticate
Data: `{ "userId": username, "password": password  }`
<label for="username">CROMERR username: <input id="username"></label>
<label for="password">CROMERR password: <input id="password"></label>
<a href="javascript:authenticateUser();">Run »</a>

Response:
<pre><code id="authenticate-user-response"></code></pre>

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
    $.get('/reset', function(data) {
      alert(data);
    });
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
      res += "\n" + data;
      $('#authenticate-user-response').text(res);
    });
  }
  

</script>

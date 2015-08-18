---
title: API Diagnostics
permalink: /api-diagnostics/
---

# Submit Manifest

**POST** /api/manifest/submit/12345
Data: `<xml>My Manifest</xml>`
<a href="javascript:submitManifest();">Run »</a>

Response:
<pre><code id="submit-manifest-response"></code></pre>

# Search for Manifests

**GET** /api/manifest/search**?city=madison&state=wi**
<a href="javascript:searchManifest();">Run »</a>

Response:
<pre><code id="search-manifest-response"></code></pre>

# Update Manifest

**PATCH** /api/manifest/update/12345
<a href="javascript:updateManifest();">Run »</a>

Response:
<pre><code id="update-manifest-response"></code></pre>


<script>
  
  function prettyJson(data) {
    return JSON.stringify(data, null, 2);
  }
  
  function submitManifest() {
    $.ajax({
      type: 'POST',
      url: '/api/manifest/submit/12345',
      data: '<xml>My Manifest</xml>'
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + data;
      $('#submit-manifest-response').text(res);
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
  
  function updateManifest() {
    $.ajax({
      type: 'PATCH',
      url: '/api/manifest/update/12345',
    })
    .done(function(data, textStatus, xhr) {
      var res = xhr.status + " " + xhr.statusText;
      res += "\n" + prettyJson(data);
      $('#update-manifest-response').text(res);
    });
  }
  
</script>

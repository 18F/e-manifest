---
title: API Documentation
subtitle: Endpoints for the e-Manifest application programming interfaces (API).
permalink: /api-documentation/

breadcrumbs:
  - text: Home
    link: /
---

Base URL: **e-manifest.18f.gov/api**

{% for endpoint in site.data.api %}

<table class="api">
  <thead>
    <tr>
      <th colspan="2"><h2>{{ endpoint.title  }}</h2></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Description</td>
      <td>{{ endpoint.description }}</td>
    </tr>
    <tr>
      <td>HTTP Verb</td>
      <td><b>{{ endpoint.http_verb }}</b></td>
    </tr>
    <tr>
      <td>Resource URL</td>
      <td><b>{{ endpoint.resource_url }}</b></td>
    </tr>
    {% if endpoint.parameters %}
    <tr>
      <td>Parameters</td>
      <td><pre><code>{{ endpoint.parameters }}</code></pre></td>
    </tr>
    {% endif %}
    <tr>
      <td>Response format</td>
      <td>{{ endpoint.response_format }}</td>
    </tr>
    <tr>
      <td>Response</td>
      <td><pre><code>{{ endpoint.response }}</code></pre></td>
    </tr>
  </tbody>
</table>

{% endfor %}

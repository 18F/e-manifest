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
    {% if endpoint.path_variables %}
    <tr>
      <td>Path variables</td>
      <td>
        <dl>
      {% for path_variable in endpoint.path_variables %}
        <dt>{{ path_variable[0] }}</dt>
        <dd>{{ path_variable[1] }}</dd>
      {% endfor %}
        </dl>
      </td>
    </tr>
    {% endif %}
    {% if endpoint.parameters %}
    <tr>
      <td>Parameters</td>
      <td><pre><code>{{ endpoint.parameters }}</code></pre></td>
    </tr>
    {% endif %}
    {% if endpoint.request_body %}
    <tr>
      <td>Request body</td>
      <td><pre><code>{{ endpoint.request_body }}</code></pre></td>
    </tr>
    {% endif %}
    {% if endpoint.request_body_parameters %}
    <tr>
      <td>Request body parameters</td>
      <td>
        <dl>
      {% for request_body_parameter in endpoint.request_body_parameters %}
        <dt>{{ request_body_parameter[0] }}</dt>
        <dd>{{ request_body_parameter[1] }}</dd>
      {% endfor %}
        </dl>
      </td>
    </tr>
    {% endif %}
    <tr>
      <td>Response format</td>
      <td>{{ endpoint.response_format }}</td>
    </tr>
    {% if endpoint.response %}
    <tr>
      <td>Response</td>
      <td><pre><code>{{ endpoint.response }}</code></pre></td>
    </tr>
    {% endif %}
    {% if endpoint.response_details %}
    <tr>
      <td>Response details</td>
      <td>{{ endpoint.response_details }}</td>
    </tr>
    {% endif %}
  </tbody>
</table>

{% endfor %}

class ApiDocumentationController < ApplicationController
  def examples
    render 'api-docs/examples/index'
  end

  def swagger
    render 'api-docs/swagger/index', layout: false
  end
end

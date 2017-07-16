class IssuesController < ApplicationController
  IndexQuery = GitHub::Client.parse <<-'GRAPHQL'
    query {
      ...Views::Issues::Index::Viewer
    }
  GRAPHQL

  # GET /issues
  def index
    data = query IndexQuery

    render "issues/index", locals: {
      viewer: data.viewer
    }
  end
end

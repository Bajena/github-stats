class UsersController < ApplicationController
  ORGANIZATION_NAME = "Leadfeeder"

  IndexQuery = GitHub::Client.parse <<-'GRAPHQL'
    query {
      organization(login: "Leadfeeder") {
        members(first: 100) {
          edges {
            node {
              login
            }
          }
        }
      }
    }
  GRAPHQL

  IssueSearchQuery = GitHub::Client.parse <<-'GRAPHQL'
    query($query: String!) {
      search(first: 0, type: ISSUE, query: $query) {
        issueCount
      }
    }
  GRAPHQL

  def index
    index_query = query IndexQuery

    data = []

    index_query.organization.members.each_node do |user|
      login = user.login
      merged_prs = search_result "author:#{login} is:merged user:#{ORGANIZATION_NAME} type:pr"
      open_prs = search_result "author:#{login} is:open user:#{ORGANIZATION_NAME} type:pr"
      rotting_prs = search_result "author:#{login} is:open user:#{ORGANIZATION_NAME} type:pr created:<#{Date.current - 7.days}"
      assigned_issues = search_result "author:#{login} is:open user:#{ORGANIZATION_NAME} type:issue"
      review_requests = search_result "review-requested:#{login} is:open user:#{ORGANIZATION_NAME} type:pr"
      mentions_last_week = search_result "mentions:#{login} user:#{ORGANIZATION_NAME} updated:#{Date.current - 7.days}..#{Date.current}"

      data << UserData.new.tap do |d|
        d.login = login
        d.merged_prs = merged_prs.issueCount
        d.open_prs = open_prs.issueCount
        d.rotting_prs = rotting_prs.issueCount
        d.assigned_issues = assigned_issues.issueCount
        d.review_requests = review_requests.issueCount
        d.mentions_last_week = mentions_last_week.issueCount
      end
    end


    render "users/index", locals: {
      data: data
    }
  end

  private

  def search_result(search_query)
    query(IssueSearchQuery, query: search_query).search
  end
end

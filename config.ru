require 'rack/app'
require 'httparty'
require 'logger'
require 'pry'

require_relative 'github_wrapper'

class App < Rack::App


  desc 'assign_reviewers'
  post '/assign_reviewers' do
    params = JSON.parse(payload)
    pull = params['pull_request']

    if params["action"] == 'labeled' && params['label']['name'] == 'Code Review'
      requested_reviewers_count = 2 - pull['requested_reviewers'].size

      return if requested_reviewers_count <= 0

      creator = pull.dig(*%w(user login))

      logins = GithubWrapper.team_members.map { |m| m['login'] }
      logins.delete(creator)
      reviewers = logins.sample(requested_reviewers_count)

      GithubWrapper.request_review(pull['url'], reviewers)
      SlackWrapper.notify_reviewers(pull['url'], reviewers)
    end
  end

end

run App

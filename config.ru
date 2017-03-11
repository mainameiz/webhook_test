require 'rack/app'
require 'httparty'
require 'logger'
require 'pry'

require_relative 'request_review'

class App < Rack::App

  TEAM_URL = ENV['TEAM_URL']

  desc 'assign_reviewers'
  post '/assign_reviewers' do
    params = JSON.parse(payload)
    pull = params['pull_request']

    if params["action"] == 'labeled' && params['label']['name'] == 'Code Review'
      requested_reviewers_count = 2 - pull['requested_reviewers'].size

      return if requested_reviewers_count <= 0

      creator = pull.dig(*%w(user login))

      team_members = JSON.parse(HTTParty.get(TEAM_URL,
        basic_auth: { user: LOGIN, password: TOKEN },
        headers: { 'User-Agent' => LOGIN }).body)

      logins = team_members.map { |m| m['login'] }
      logins.delete(creator)
      reviewers = logins.sample(requested_reviewers_count)

      RequestReview.call(reviewers)
    end
  end

end

run App

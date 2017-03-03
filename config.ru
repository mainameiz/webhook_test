require 'rack/app'
require 'httparty'
require 'logger'
require 'pry'

class App < Rack::App

  LOGIN = ENV['GITHUB_LOGIN']
  TOKEN = ENV['GITHUB_TOKEN']
  TEAM_URL = ENV['TEAM_URL']

  desc 'assign_reviewers'
  post '/assign_reviewers' do
    params = JSON.parse(payload)
    pull = params['pull_request']

    if params["action"] == 'labeled' && params['label']['name'] == 'Code Review'
      assignees_count = 2 - pull['requested_reviewers'].size

      return if requested_reviewers_count <= 0

      creator = pull.dig(*%w(user login))
      # teams_url = params.dig(*%w(repository teams_url))

      team_members = JSON.parse(HTTParty.get(TEAM_URL,
        basic_auth: { user: LOGIN, password: TOKEN },
        headers: { 'User-Agent' => LOGIN }).body)

      logins = team_members.map { |m| m['login'] }
      logins.delete(creator)
      requested_reviewers = logins.sample(requested_reviewers_count)

      HTTParty.post(
        "#{pull['url'].gsub('pulls', 'issues')}/requested_reviewers",
        body: { "reviewers": assignees }.to_json,
        basic_auth: { user: LOGIN, password: TOKEN },
        headers: {
          'User-Agent' => LOGIN,
          'Accept' => 'application/vnd.github.black-cat-preview+json'
        }
      )
    end
  end

end

run App

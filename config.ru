require 'rack/app'
require 'httparty'
require 'logger'
require 'pry'

require_relative 'github_wrapper'
require_relative 'slack_wrapper'

class App < Rack::App
  REVIEWERS_COUNT = ENV.key?('REVIEWERS_COUNT') ? ENV['REVIEWERS_COUNT'].to_i : 2

  STDOUT.sync = true
  apply_extensions :logger

  desc 'assign_reviewers'
  post '/assign_reviewers' do
    logger.info 'asdasd'
    params = JSON.parse(payload)
    pull = params['pull_request']

    logger.info "action: #{params['action'].inspect}"
    logger.info("label: #{params['label']['name'].inspect}") if params['action'] == 'labeled'
    if params["action"] == 'labeled' && params['label']['name'] == 'Code Review'
      requested_reviewers_count = REVIEWERS_COUNT - pull['requested_reviewers'].size

      return if requested_reviewers_count <= 0

      creator = pull.dig(*%w(user login))

      logins = GithubWrapper.team_members.map { |m| m['login'] }
      logins.delete(creator)
      reviewers = logins.sample(requested_reviewers_count)

      GithubWrapper.request_review(pull['url'], reviewers)

      pull_url = pull['url'].gsub(/(api.|repos\/)/, '').gsub('pulls', 'issues')
      SlackWrapper.notify_reviewers(pull_url, reviewers)
    end
  end

end

run App

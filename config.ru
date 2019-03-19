require 'rack/app'
require 'httparty'
require 'logger'
require 'pry'

require_relative 'github_wrapper'
require_relative 'slack_wrapper'

STDOUT.sync = true

class App < Rack::App
  REVIEWERS_COUNT = ENV.key?('REVIEWERS_COUNT') ? ENV['REVIEWERS_COUNT'].to_i : 2

  apply_extensions :logger

  desc 'assign_reviewers'
  post '/assign_reviewers' do
    params = JSON.parse(payload)
    pull = params['pull_request']

    action = params['action']
    labeled = (action == 'labeled')
    logger.info("action: #{action.inspect}")
    return unless labeled

    label_name = params['label']['name']
    logger.info("label: #{label_name.inspect}")
    return if label_name != 'Code Review'

    requested_reviewers_count = REVIEWERS_COUNT - pull['requested_reviewers'].size

    return if requested_reviewers_count <= 0

    creator = pull.dig(*%w(user login))

    logins = GithubWrapper.team_members.map { |m| m['login'] }
    logins.delete(creator)
    reviewers = logins.sample(requested_reviewers_count)

    github_response = GithubWrapper.request_review(pull['url'], reviewers)
    unless github_response.success?
      response.status = github_response.code
      return github_response.body
    end

    pull_url = pull['url'].gsub(/(api.|repos\/)/, '').gsub('pulls', 'issues')
    SlackWrapper.notify_reviewers(pull_url, reviewers)
  end

end

run App

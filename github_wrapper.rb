module GithubWrapper

  TEAM_URL = ENV['TEAM_URL']
  LOGIN = ENV['GITHUB_LOGIN']
  TOKEN = ENV['GITHUB_TOKEN']

  module_function

  def request_review(url, requested_reviewers)
    request = HTTParty.post(
        "#{url}/requested_reviewers",
        body: { "reviewers": requested_reviewers }.to_json,
        basic_auth: { user: LOGIN, password: TOKEN },
        headers: {
          'User-Agent' => LOGIN,
          'Accept' => 'application/vnd.github.black-cat-preview+json'
        }
      )

    request
  end

  def team_members
    request = HTTParty.get(
      TEAM_URL,
      basic_auth: { user: LOGIN, password: TOKEN },
      headers: { 'User-Agent' => LOGIN }
    )

    JSON.parse(request.body)
  end
end

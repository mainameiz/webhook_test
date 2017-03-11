class RequestReview

  LOGIN = ENV['GITHUB_LOGIN']
  TOKEN = ENV['GITHUB_TOKEN']

  def self.call(requested_reviewers)
    HTTParty.post(
        "#{pull['url']}/requested_reviewers",
        body: { "reviewers": requested_reviewers }.to_json,
        basic_auth: { user: LOGIN, password: TOKEN },
        headers: {
          'User-Agent' => LOGIN,
          'Accept' => 'application/vnd.github.black-cat-preview+json'
        }
      )
  end
end

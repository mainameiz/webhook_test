module SlackWrapper

  SLACK_URL = ENV['SLACK_URL']

  module_function

  def notify_reviewers(url, reviewers)
    text = "Code review #{url}"

    requests = reviewers.map do |reviewer|
      HTTParty.post(
        SLACK_URL,
        body: {
          payload: {
            channel: "@#{reviewer}",
            username: 'Code review bot',
            text: text,
            icon_emoji: ':ghost:'
          }.to_json
        }
      )
    end

    requests.all?(&:success?)
  end
end

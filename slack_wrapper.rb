module SlackWrapper

  SLACK_URL = ENV['SLACK_URL']

  BEGINNINGS = [
    'Review plz',
    'Review please',
    'Посмотри пожалуйста',
    'Глянь пожалуйта',
    ''
  ]

  module_function

  def notify_reviewers(url, reviewers)
    text = "#{BEGINNINGS.sample} #{url}"

    requests = reviewers.map do |reviewer|
      HTTParty.post(
        SLACK_URL,
        body: {
          payload: {
            channel: "@#{reviewer}",
            username: 'webhookbot',
            text: text,
            icon_emoji: ':ghost:'
          }.to_json
        }
      )
    end

    requests.all?(&:success?)
  end
end

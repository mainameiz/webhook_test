module SlackWrapper

  SLACK_URL = ENV['SLACK_URL']

  BEGINNINGS = [
    'Review plz',
    'Review please',
    'Посмотрите',
    'Посмотрите пожалуйста',
    'Гляньте',
    'Поревьюйте',
    '',
    ':code_review:'
  ]

  module_function

  def notify_reviewers(url, reviewers)
    text = "#{BEGINNINGS.sample}: #{reviewers.map { |r| "#{@r}" }.join(' ')} #{url}"

    request = HTTParty.post(
        SLACK_URL,
        body: {
          payload: {
            channel: '#review_me',
            username: 'webhookbot',
            text: text,
            icon_emoji: ':ghost:'
          }.to_json
        }
      )

    request.success?
  end
end

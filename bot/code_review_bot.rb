class CodeReviewBot < SlackRubyBot::Bot
  command 'cd-rv' do
    desc 'This will rotate through the list of users previously set'
  end
end
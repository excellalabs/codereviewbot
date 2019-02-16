# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
require ::File.expand_path('../bot/bot', __FILE__)

Thread.abort_on_exception = true
Thread.new do
  Bot.run
  CodeReviewBot.run
end
run Rails.application

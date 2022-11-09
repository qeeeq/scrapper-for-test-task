require 'capybara/poltergeist'

class InitScrapper < SimpleDelegator
  def initialize
    prepare
    __setobj__ Capybara.current_session
  end

  def prepare
    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, timeout: 5, js_errors: false)
    end
    Capybara.default_driver = :poltergeist
  end
end

require 'capybara/poltergeist'
require './scrapper_services'

class Scrapper
  attr_reader :service, :pattern, :login_params, :field_params

  def initialize(site_url, pattern = {}, login_params = {}, field_params = {})
    @service = ScrapperServices.new(site_url)
    @pattern = pattern
    @login_params = login_params
    @field_params = field_params
  end

  def scrape
    return p 'Pattern not specified.' if pattern.empty?

    service.login(login_params, field_params) unless login_params.empty?
    sleep(1)
    service.parse_specified_pattern(pattern)
  end
end

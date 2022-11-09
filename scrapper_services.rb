require 'capybara/poltergeist'
require './init_class'
require './scrapper'

class ScrapperServices
  attr_reader :site_url, :session

  def initialize(site_url)
    @site_url = site_url
    @session = InitScrapper.new
  end

  def parse_specified_pattern(pattern)
    return 'Link not found' unless page_has_link?(pattern[:html_link_name])
    # abort 'Link not found' unless page_has_link?(link_name)

    gsub_pattern = pattern[:gsub_map][:gsub_pattern]
    gsub_replacement = pattern[:gsub_map][:gsub_replacement]
    session.click_on pattern[:html_link_name]
    string = session.all(pattern[:html_element]).map(&:text).join
    
    string.scan(pattern[:regexp]).map{ |s| s.gsub(gsub_pattern, gsub_replacement) }
  end

  def visit_url
    session.visit site_url
    sleep(1)
    session.current_url
  rescue Capybara::Poltergeist::StatusFailError => e
    p "404 Not Found: #{e.message}"
  end

  def login(login_params, field_params)
    visit_url
    return false unless login_fields_found?(field_params)

    begin
      sleep(1)
      session.fill_in field_params[:login_id], with: login_params[:login]
      session.fill_in field_params[:password_id], with: login_params[:password]
      session.click_on field_params[:button_name]
      session.has_text?('Signed in successfully.')
    rescue Capybara::ElementNotFound => e
      p e
    end
  end

  def login_fields_found?(field_params)
    return false unless params_has_keys?(field_params)
    sleep(1)
    login_field = session.has_field?(field_params[:login_id])
    password_field = session.has_field?(field_params[:password_id])
    button_type = session.has_button?(field_params[:button_name])

    if login_field & password_field & button_type
      return true
    else
      return false
    end
  end

  def page_has_link?(link_name)
    session.has_link?(link_name)
  end

  def params_has_keys?(field_params)
    field_params.key?(:login_id) & field_params.key?(:password_id) & field_params.key?(:button_name)
  end
end

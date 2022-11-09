require './scrapper'

describe 'Scrapper' do
    let(:valid_url) { 'http://lit-ravine-86474.herokuapp.com/login' }
    let(:invalid_url) { 'invalid_url' }
    let(:service_with_valid_url) { ScrapperServices.new(valid_url) }
    let(:service_with_invalid_url) { ScrapperServices.new(invalid_url) }

    let(:valid_login_params) { { login: '+0123456789', password: '123123' } }
    let(:invalid_login_params) { { login: 'asd', password: '' } }
    let(:valid_field_params) { { login_id: 'user_phone', password_id: 'user_password', button_name: 'commit' } }
    let(:invalid_field_params) { { login_id: 'phone' } }
    let(:invalid_link_name) { 'dsasd' }
    
    let(:pattern) {
      {
        html_element: '#index_table_patients',
        html_link_name: 'Patients',
        regexp: /\d+.\d+.\d+/,
        gsub_map: { gsub_pattern: /\D+/,  gsub_replacement: '' }
      }
    }

  context ScrapperServices do
    it '#visit_url' do
      message = "404 Not Found: Request to '#{invalid_url}' failed to reach server, check DNS and/or server status"
      
      expect(service_with_valid_url.visit_url).to eq valid_url
      expect(service_with_invalid_url.visit_url).to eq message
      # expect { service_with_invalid_url.visit_url }.to raise_error(Capybara::Poltergeist::StatusFailError)
    end

    it '#login_fields_found?' do
      valid_result = service_with_valid_url.login_fields_found?(valid_field_params)
      invalid_result = service_with_valid_url.login_fields_found?(invalid_field_params)

      expect(valid_result).to be true
      expect(invalid_result).to be false
    end

    it '#login should be success' do
      service_with_valid_url.login(valid_login_params, valid_field_params)
      expect(service_with_valid_url.session).to have_content('Signed in successfully.')
    end

    it '#login should be failed' do
      Capybara.reset_sessions!
      service_with_valid_url.login(invalid_login_params, valid_field_params)

      expect(service_with_valid_url.session).to have_content('Invalid Phone or password.')
    end

    it '#page_has_link?' do
      Capybara.reset_sessions!
      service_with_valid_url.login(valid_login_params, valid_field_params)
      valid_result = service_with_valid_url.page_has_link?(pattern[:html_link_name])
      invalid_result = service_with_valid_url.page_has_link?(invalid_link_name)

      expect(valid_result).to be true
      expect(invalid_result).to be false
    end

    it '#parse_specified_pattern' do
      Capybara.reset_sessions!
      service_with_valid_url.login(valid_login_params, valid_field_params)
      result = service_with_valid_url.parse_specified_pattern(pattern)

      expect(result.first).to eq ('1326168841')
    end
  end

  context Scrapper do
    let(:site_url) { 'http://lit-ravine-86474.herokuapp.com/login' }

    before(:each) do
      Capybara.reset_sessions!
    end

    it '#scrape should be success' do
      parser = Scrapper.new(site_url, pattern, valid_login_params, valid_field_params)
      result = parser.scrape

      expect(result.first).to eq ('1326168841')
    end

    it '#scrape should be failed' do
      pattern[:html_link_name] = invalid_link_name
      parser = Scrapper.new(site_url, pattern, valid_login_params, valid_field_params)
      result = parser.scrape

      expect(result).to eq ('Link not found')
    end
  end
end

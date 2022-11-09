require './scrapper'

site_url = 'http://lit-ravine-86474.herokuapp.com/login'
valid_link_name = 'Patients'
invalid_link_name = 'dsasd'

pattern = {
  html_element: '#index_table_patients',
  html_link_name: 'Patients',
  regexp: /\d+.\d+.\d+/, gsub_map: { gsub_pattern: /\D+/, gsub_replacement: '' }
}
empty_pattern = {}

valid_login_params = { login: '+0123456789', password: '123123' }
invalid_login_params = { login: '', password: '' }

valid_field_params = { login_id: 'user_phone', password_id: 'user_password', button_name: 'commit' }
invalid_field_params = { login_id: 'asd' }

# run_scrapper
  parser = Scrapper.new(site_url, pattern, valid_login_params, valid_field_params)
  result = parser.send :scrape
  p result

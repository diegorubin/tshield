class HomePage < SitePrism::Page
  set_url $env['pages']['home']['url']
  element :search_input, '[data-test-search-input]'
  element :submit_button, '[data-test-search-button]'
  element :card_result_name, '[data-test-card-name]'
  element :card_result_comic, '[data-test-card-comic]'
  element :card_result_img, '[data-test-card-img]'
  element :card_error_title, '[data-test-card-error-title]'
  element :card_error_msg, '[data-test-card-error-msg]'

  def fill_search(search)
    search_input.click
    search_input.set search
  end

  def submit
    submit_button.click
  end

  def do_search(search)
    fill_search(search)
    submit
  end

end


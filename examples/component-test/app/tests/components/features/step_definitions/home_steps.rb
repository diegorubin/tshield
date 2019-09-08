# frozen_string_literal: true

Quando('acesso a página e realizo uma busca válida') do
  start_session('valid')
  @page = HomePage.new
  @page.load
end

Então('vejo o resultado da busca') do
  expect(page).to have_current_path('/')
end

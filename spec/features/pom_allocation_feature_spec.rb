require 'rails_helper'

feature 'allocate a POM' do
  it 'shows the allocate a POM page', vcr: { cassette_name: :pom_allocation_feature, match_requests_on: [:query] } do
    signin_user
    noms_id = 'G4273GI'

    visit allocate_show_path(noms_id)

    expect(page).to have_css('h1', text: 'Allocate a Prison Offender Manager')
    expect(page).not_to have_css('.govuk-breadcrumbs')
  end
end

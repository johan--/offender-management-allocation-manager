require 'rails_helper'

feature 'Allocation' do
  let!(:probation_officer_nomis_staff_id) { 485_636 }
  let!(:prison_officer_nomis_staff_id) { 485_752 }
  let!(:nomis_offender_id) { 'G4273GI' }

  let!(:probation_officer_pom_detail) {
    PomDetail.create!(
      nomis_staff_id: probation_officer_nomis_staff_id,
      working_pattern: 1.0,
      status: 'Active'
  )
  }

  let!(:case_information) {
    CaseInformation.create!(nomis_offender_id: nomis_offender_id, tier: 'A', case_allocation: 'NPS')
  }

  scenario 'accepting a recommended allocation', vcr: { cassette_name: :create_allocation_feature } do
    signin_user

    visit new_allocations_path(nomis_offender_id)

    within('.recommended_pom_row_0') do
      click_link 'Allocate'
    end

    expect(page).to have_css('h1', text: 'Confirm allocation')
    expect(page).to have_css('p', text: 'You are allocating Abbella, Ozullirn to Retallick, Toby')

    click_button 'Complete allocation'

    expect(page).to have_current_path summary_path
  end

  scenario 'overriding an allocation', vcr: { cassette_name: :override_allocation_feature } do
    override_nomis_staff_id = 485_752

    signin_user

    visit new_allocations_path(nomis_offender_id)

    within('.not_recommended_pom_row_0') do
      click_link 'Allocate'
    end

    expect(page).to have_css('h1', text: 'Choose reason for changing recommended grade')

    check('override-1')
    check('override-2')
    click_button('Continue')

    expect(Override.count).to eq(1)

    expect(page).to have_current_path confirm_allocations_path(nomis_offender_id, override_nomis_staff_id)

    click_button 'Complete allocation'

    expect(page).to have_current_path summary_path
    expect(Override.count).to eq(0)
  end

  scenario 'overriding an allocation can validate missing reasons', vcr: { cassette_name: :override_allocation_feature } do
    signin_user

    visit new_allocations_path(nomis_offender_id)

    within('.not_recommended_pom_row_0') do
      click_link 'Allocate'
    end

    expect(page).to have_css('h1', text: 'Choose reason for changing recommended grade')

    click_button('Continue')
    expect(page).to have_content('Override reasons must be provided')
    expect(Override.count).to eq(0)
  end

  scenario 'overriding an allocation can validate missing Other detail', vcr: { cassette_name: :override_allocation_feature } do
    signin_user

    visit new_allocations_path(nomis_offender_id)

    within('.not_recommended_pom_row_0') do
      click_link 'Allocate'
    end

    expect(page).to have_css('h1', text: 'Choose reason for changing recommended grade')

    check('override-conditional-4')
    click_button('Continue')
    expect(page).to have_content('More detail must be provided when Other is selected')
    expect(Override.count).to eq(0)
  end

  scenario 're-allocating', vcr: { cassette_name: :re_allocate_feature } do
    probation_officer_pom_detail.allocations.create!(
      nomis_offender_id: nomis_offender_id,
      nomis_staff_id: probation_officer_nomis_staff_id,
      nomis_booking_id: 1_153_753,
      prison: 'LEI',
      allocated_at_tier: 'A',
      created_by: 'spo@leeds.hmpps.gov.uk',
      active: true
    )

    signin_user

    visit '/summary#allocated'

    within('.allocated_offender_row_0') do
      click_link 'Reallocate'
    end

    expect(page).to have_current_path edit_allocations_path(nomis_offender_id)
    expect(page).to have_css('.current_pom_full_name', text: 'Duckett, Jenny')
    expect(page).to have_css('.current_pom_grade', text: 'Prison POM')
  end
end
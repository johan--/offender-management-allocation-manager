require 'rails_helper'

RSpec.describe MovementsOnDateJob, type: :job do
  let(:nomis_offender_id) { 'G1916EU' }
  let!(:alloc) { create(:allocation_version, nomis_offender_id: nomis_offender_id, secondary_pom_nomis_id: 123_435, prison: 'MDI') }
  let(:elite2api) { 'https://gateway.t3.nomis-api.hmpps.dsd.io/elite2api/api' }

  before do
    stub_auth_token
  end

  it 'deallocates' do
    stub_request(:get, "#{elite2api}/movements?fromDateTime=2019-06-29T00:00&movementDate=2019-06-30").
      to_return(status: 200, body: [
        { offenderNo: nomis_offender_id,
          fromAgency: "MDI",
          toAgency: "WEI",
          movementType: "ADM",
          directionCode: "IN"
        }].to_json, headers: {})

    expect(alloc.primary_pom_nomis_id).not_to be_nil
    expect(alloc.secondary_pom_nomis_id).not_to be_nil

    described_class.perform_now(Date.new(2019, 07, 1).to_s)

    alloc.reload

    expect(alloc.primary_pom_nomis_id).to be_nil
    expect(alloc.secondary_pom_nomis_id).to be_nil
  end
end

require 'rails_helper'

describe Nomis::Keyworker::KeyworkerApi do
  before do
    stub_request(:get, "https://keyworker-api-dev.prison.service.justice.gov.uk/key-worker/LEI/offender/G4273GI").
     to_return(status: 200, body: {
       staffId: 1,
       firstName: 'DOM',
       lastName: 'JONES'
     }.to_json)
    stub_request(:get, "https://keyworker-api-dev.prison.service.justice.gov.uk/key-worker/LEI/offender/GGGGGGG").
    to_return(status: 404)
  end

  describe 'Keyworkers' do
    let(:location) { 'LEI' }

    it 'can get details for a Keyworker' do
      offender_no = 'G4273GI'
      response = described_class.get_keyworker(location, offender_no)

      expect(response).to be_instance_of(Nomis::KeyworkerDetails)
      expect(response.first_name).to eq('DOM')
    end

    it 'returns nullkeyworker if unable find a Keyworker' do
      unknown_offender_no = 'GGGGGGG'
      response = described_class.get_keyworker(location, unknown_offender_no)

      expect(response).to be_instance_of(Nomis::NullKeyworker)
    end
  end
end

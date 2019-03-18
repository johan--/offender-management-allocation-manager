require 'rails_helper'

RSpec.describe EmailService do
  include ActiveJob::TestHelper
  let(:params) {
    {
      nomis_staff_id: 485_637,
      nomis_offender_id: 'G2911GD',
      created_by: "PK000223",
      nomis_booking_id: 1_153_753,
      allocated_at_tier: "A",
      prison: "LEI",
      override_reasons: nil,
      override_detail: nil,
      message: "",
      pom_detail_id: 5
    }
  }

  before(:each) {
    ActiveJob::Base.queue_adapter = :test
    PomDetail.create(nomis_staff_id: 485_637, working_pattern: 1.0, status: 'inactive')
  }

  context "when creating an initial POM allocation" do
    it "Can send an allocation email", vcr: { cassette_name: 'email_service_send_allocation_email' } do
      described_class.send_allocation_email(params)
      expect(enqueued_jobs.size).to eq(1)
      enqueued_jobs.clear
    end
  end

  context "when allocating a prisoner to another POM" do
    it "Can send an allocation email", vcr: { cassette_name: 'email_service_send_deallocation_email' } do
      allow(Allocation).to receive(:where).and_return([
          Allocation.new.tap do |a|
            a.nomis_staff_id = 485_737
            a.nomis_offender_id = 'G2911GD'
            a.created_by = 'Test User'
            a.nomis_booking_id = 0
            a.allocated_at_tier = 'A'
            a.prison = 'LEI'
          end
                                                      ])
      described_class.send_allocation_email(params)
      expect(enqueued_jobs.size).to eq(2)
      enqueued_jobs.clear
    end
  end
end
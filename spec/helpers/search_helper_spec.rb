require 'rails_helper'

RSpec.describe SearchHelper do
  describe 'the CTA' do
    it "will change to edit if there is no tier" do
      offender = Nomis::Models::Offender.new(
        offender_no: 'A'
      )
      text, _link = cta_for_offender(offender)
      expect(text).to eq('<a href="/case_information/new/A">Edit</a>')
    end

    it "will change to allocate if there is no allocation" do
      offender = Nomis::Models::Offender.new(
        offender_no: 'A',
        tier: 'A'
      )
      text, _link = cta_for_offender(offender)
      expect(text).to eq('<a href="/allocations/new/A">Allocate</a>')
    end

    it "will change to reallocate if there is an allocation" do
      offender = Nomis::Models::Offender.new(
        offender_no: 'A',
        tier: 'A',
        allocated_pom_name: 'Bob'
      )
      text, _link = cta_for_offender(offender)
      expect(text).to eq('<a href="/allocations/new/A">Reallocate</a>')
    end
  end
end
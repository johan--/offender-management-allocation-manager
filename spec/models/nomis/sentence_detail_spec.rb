require "rails_helper"

describe Nomis::SentenceDetail, model: true do
  let(:date) { Date.new(2019, 2, 3) }
  let(:override) { Date.new(2019, 5, 3) }

  describe "#automatic_release_date" do
    context "when override present" do
      before do
        subject.automatic_release_date = date
        subject.automatic_release_override_date = override
      end

      it "overrides" do
        expect(subject.automatic_release_date).to eq(override)
      end
    end

    context "without override" do
      before do
        subject.automatic_release_date = date
        subject.automatic_release_override_date = nil
      end

      it "uses original" do
        expect(subject.automatic_release_date).to eq(date)
      end
    end
  end

  describe "#conditional_release_date" do
    context "when override present" do
      before do
        subject.conditional_release_date = date
        subject.conditional_release_override_date = override
      end

      it "overrides" do
        expect(subject.conditional_release_date).to eq(override)
      end
    end

    context "without override" do
      before do
        subject.conditional_release_date = date
      end

      it "uses original" do
        expect(subject.conditional_release_date).to eq(date)
      end
    end
  end

  describe "#recall_release_date" do
    let(:earlier_date) { Date.new(2019, 2, 3) }
    let(:later_date) { Date.new(2019, 5, 4) }
    let(:no_date) { nil }

    context "actual_parole_date exists and comes before post_recall_release_override_date" do
      before do
        subject.actual_parole_date = earlier_date
        subject.post_recall_release_override_date = later_date
        subject.post_recall_release_date = no_date
      end

      it "shows actual_parole_date" do
        expect(subject.recall_release_date).to eq(earlier_date)
      end
    end

    context "actual_parole_date exists and comes after post_recall_release_override_date" do
      before do
        subject.actual_parole_date = later_date
        subject.post_recall_release_override_date = earlier_date
      end

      it "shows post_recall_release_override_date" do
        expect(subject.recall_release_date).to eq(earlier_date)
      end
    end

    context "actual_parole_date is not present and post_recall_release_override_date is" do
      before do
        subject.actual_parole_date = no_date
        subject.post_recall_release_override_date = earlier_date
      end

      it "shows post_recall_release_override_date" do
        expect(subject.recall_release_date).to eq(earlier_date)
      end
    end

    context "actual_parole_date is not present and post_recall_release_override_date is not present" do
      before do
        subject.actual_parole_date = no_date
        subject.post_recall_release_override_date = no_date
        subject.post_recall_release_date = earlier_date
      end

      it "shows post_recall_release_date" do
        expect(subject.recall_release_date).to eq(earlier_date)
      end
    end

    context "actual_parole_date, post_recall_release_override_date and post_recall_release_date are not present" do
      before do
        subject.actual_parole_date = no_date
        subject.post_recall_release_override_date = no_date
        subject.post_recall_release_date = no_date
      end

      it "shows nil" do
        expect(subject.recall_release_date).to eq(no_date)
      end
    end
  end
end

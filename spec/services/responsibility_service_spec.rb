require 'rails_helper'

describe ResponsibilityService do
  describe '#calculate_pom_responsibility' do
    context 'when offender is english' do
      let(:offender) {
        OpenStruct.new welsh_offender: false,
                       case_allocation: case_allocation,
                       indeterminate_sentence?: indeterminate_sentence,
                       recalled?: recalled,
                       sentence_start_date: start_date,
                       earliest_release_date: release_date,
                       parole_eligibility_date: parole_date,
                       sentenced?: true
      }

      let(:parole_date) { nil }
      let(:indeterminate_sentence) { false }
      let(:recalled) { false }

      context 'when sentenced before 30th Sept' do
        let(:start_date) { Date.new(2019, 9, 18) }

        context 'when NPS' do
          let(:case_allocation) { 'NPS' }

          context 'with over 17 months left to serve' do
            let(:release_date) { Date.new(2019, 10, 1) + 18.months }

            it 'is responsible' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::RESPONSIBLE
            end
          end

          context 'with < 17 months left' do
            let(:release_date) { Date.new(2019, 10, 1) + 16.months }

            it 'is supporting' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end

          context 'when inderminate' do
            let(:release_date) { parole_date }
            let(:inderminate_sentence) { true }

            context 'with ped > 17 months away' do
              let(:parole_date) { DateTime.now.utc.to_date + 18.months }

              it 'is responsible' do
                resp = described_class.calculate_pom_responsibility(offender)

                expect(resp).to eq ResponsibilityService::RESPONSIBLE
              end
            end

            context 'with ped < 17 months away' do
              let(:parole_date) { DateTime.now.utc.to_date + 16.months }

              it 'is supporting' do
                resp = described_class.calculate_pom_responsibility(offender)

                expect(resp).to eq ResponsibilityService::SUPPORTING
              end
            end
          end
        end

        context 'when CRC' do
          let(:case_allocation) { 'CRC' }

          context 'with > 12 weeks left to serve' do
            let(:release_date) { DateTime.now.utc.to_date + 13.weeks }

            it 'is reponsible' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::RESPONSIBLE
            end
          end

          context 'with < 12 weeks left to serve' do
            let(:release_date) { DateTime.now.utc.to_date + 11.weeks }

            it 'is supporting' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end
        end

        context 'when recalled' do
          let(:release_date) { Date.new(2019, 12, 1) }
          let(:recalled) { true }

          %w[NPS CRC].each do |case_allocation|
            let(:case_allocation) { case_allocation }

            it 'is always supporting' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end
        end
      end

      context 'when sentenced after 1st Oct' do
        let(:start_date) { Date.new(2019, 10, 18) }

        context 'when NPS' do
          let(:case_allocation) { 'NPS' }

          context 'when < 10 months left to serve' do
            let(:release_date) { DateTime.now.utc.to_date + 9.months }

            it 'is supporting' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end

          context 'when > 10 months left to serve' do
            let(:release_date) { DateTime.now.utc.to_date + 11.months }

            it 'is responsible' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::RESPONSIBLE
            end
          end

          context 'when indeterminate' do
            let(:release_date) { nil }

            it 'is responsible' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::RESPONSIBLE
            end
          end
        end

        context 'when CRC' do
          let(:case_allocation) { 'CRC' }

          context 'with > 12 weeks left to serve' do
            let(:release_date) { DateTime.now.utc.to_date + 13.weeks }

            it 'is reponsible' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::RESPONSIBLE
            end
          end

          context 'with < 12 weeks left to serve' do
            let(:release_date) { DateTime.now.utc.to_date + 11.weeks }

            it 'is supporting' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end
        end

        context 'when recalled' do
          let(:release_date) { Date.new(2020, 12, 1) }
          let(:recalled) { true }

          context 'when determinate' do
            let(:inderminate) { false }

            context 'when NPS' do
              let(:case_allocation) { 'NPS' }

              it 'is supporting' do
                resp = described_class.calculate_pom_responsibility(offender)

                expect(resp).to eq ResponsibilityService::SUPPORTING
              end
            end

            context 'when CRC' do
              let(:case_allocation) { 'CRC' }

              it 'is supporting' do
                resp = described_class.calculate_pom_responsibility(offender)

                expect(resp).to eq ResponsibilityService::SUPPORTING
              end
            end
          end

          # CRC indeterminate recall shouldn't be possible.
          context 'when indeterminate' do
            let(:case_allocation) { 'NPS' }
            let(:inderminate) { true }

            it 'is supporting' do
              resp = described_class.calculate_pom_responsibility(offender)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end
        end
      end
    end

    context 'when offender is Welsh' do
      context 'when CRC case' do
        let(:offender) {
          Nomis::Offender.new.tap { |o|
            o.welsh_offender = true
            o.case_allocation = 'CRC'
            o.sentence = Nomis::SentenceDetail.new
            o.sentence.release_date = release_date
          }
        }

        context 'when offender has less than 12 weeks to serve' do
          let(:release_date) { DateTime.now.utc.to_date + 2.weeks }

          it 'is supporting' do
            resp = described_class.calculate_pom_responsibility(offender)

            expect(resp).to eq ResponsibilityService::SUPPORTING
          end
        end

        context 'when offender has more than twelve weeks to serve' do
          let(:release_date) { DateTime.now.utc.to_date + 13.weeks }

          it 'is responsible' do
            resp = described_class.calculate_pom_responsibility(offender)

            expect(resp).to eq ResponsibilityService::RESPONSIBLE
          end
        end
      end

      context 'when NPS case' do
        context 'when new case (sentence date after February 4 2019)' do
          let(:offender_welsh_nps_new_case_gt_10_mths) {
            Nomis::Offender.new.tap { |o|
              o.welsh_offender = true
              o.case_allocation = 'NPS'
              o.sentence = Nomis::SentenceDetail.new
              o.sentence.sentence_start_date = DateTime.new(2019, 2, 19).utc
              o.sentence.release_date = DateTime.now.utc.to_date + 11.months
            }
          }

          let(:offender_welsh_nps_new_case_lt_10_mths) {
            Nomis::Offender.new.tap { |o|
              o.welsh_offender = true
              o.case_allocation = 'NPS'
              o.sentence = Nomis::SentenceDetail.new
              o.sentence.sentence_start_date = DateTime.new(2019, 2, 20).utc
              o.sentence.release_date = DateTime.now.utc.to_date + 9.months
            }
          }

          context 'when time left to serve is greater than 10 months' do
            it 'is responsible' do
              resp = described_class.calculate_pom_responsibility(offender_welsh_nps_new_case_gt_10_mths)

              expect(resp).to eq ResponsibilityService::RESPONSIBLE
            end
          end

          context 'when time left to serve is less than 10 months' do
            it 'is supporting' do
              resp = described_class.calculate_pom_responsibility(offender_welsh_nps_new_case_lt_10_mths)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end
        end

        context 'when old case (sentence date before February 4 2019)' do
          let(:offender_welsh_nps_old_case_gt_15_mths) {
            Nomis::Offender.new.tap { |o|
              o.welsh_offender = true
              o.case_allocation = 'NPS'
              o.sentence = Nomis::SentenceDetail.new
              o.sentence.sentence_start_date = DateTime.new(2019, 1, 19).utc
              o.sentence.release_date = Date.new(2019, 2, 4) + 16.months
            }
          }

          let(:offender_welsh_nps_old_case_lt_15_mths) {
            Nomis::Offender.new.tap { |o|
              o.welsh_offender = true
              o.case_allocation = 'NPS'
              o.sentence = Nomis::SentenceDetail.new
              o.sentence.sentence_start_date = DateTime.new(2019, 1, 20).utc
              o.sentence.release_date = Date.new(2019, 2, 4) + 14.months
            }
          }

          context 'when time left to serve is greater than 15 months from February 4 2019' do
            it 'is responsible' do
              resp = described_class.calculate_pom_responsibility(offender_welsh_nps_old_case_gt_15_mths)

              expect(resp).to eq ResponsibilityService::RESPONSIBLE
            end
          end

          context 'when time left to serve is less than 15 months from February 4 2019' do
            it 'is supporting' do
              resp = described_class.calculate_pom_responsibility(offender_welsh_nps_old_case_lt_15_mths)

              expect(resp).to eq ResponsibilityService::SUPPORTING
            end
          end
        end
      end
    end
  end
end

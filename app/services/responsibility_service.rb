# frozen_string_literal: true

class ResponsibilityService
  Responsibility = Struct.new(:description, :custody?) do
    def to_s
      description
    end
  end

  RESPONSIBLE = Responsibility.new 'Responsible', true
  SUPPORTING = Responsibility.new 'Supporting', false
  COWORKING = 'Co-Working'
  NPS = 'NPS'

  WELSH_POLICY_START_DATE = DateTime.new(2019, 2, 4).utc.to_date
  ENGLISH_POLICY_START_DATE = DateTime.new(2019, 10, 1).utc.to_date

  def self.calculate_pom_responsibility(offender)
    return RESPONSIBLE if offender.earliest_release_date.nil?

    if welsh_offender?(offender)
      welsh_rules(offender)
    else
      english_rules(offender)
    end
  end

private

  def self.welsh_rules(offender)
    if new_case?(offender)
      welsh_policy_rules(offender)
    else
      welsh_prepolicy_rules(offender)
    end
  end

  def self.english_rules(offender)
    if offender.recalled?
      SUPPORTING
    elsif new_case?(offender)
      english_policy_rules(offender)
    else
      english_prepolicy_rules(offender)
    end
  end

  def self.welsh_policy_rules(offender)
    if nps_case?(offender)
      if release_date_gt_10_mths?(offender)
        RESPONSIBLE
      else
        SUPPORTING
      end
    else
      crc_rules(offender)
    end
  end

  def self.welsh_prepolicy_rules(offender)
    if nps_case?(offender)
      if release_date_gt_15_mths?(offender)
        RESPONSIBLE
      else
        SUPPORTING
      end
    else
      crc_rules(offender)
    end
  end

  def self.english_policy_rules(offender)
    if nps_case?(offender)
      if release_date_gt_10_mths?(offender)
        RESPONSIBLE
      else
        SUPPORTING
      end
    else
      crc_rules(offender)
    end
  end

  def self.english_prepolicy_rules(offender)
    if nps_case?(offender)
      if release_date_gt_17_mths_at_policy_date?(offender)
        RESPONSIBLE
      else
        SUPPORTING
      end
    else
      crc_rules(offender)
    end
  end

  def self.crc_rules(offender)
    if release_date_gt_12_weeks?(offender)
      RESPONSIBLE
    else
      SUPPORTING
    end
  end

  def self.welsh_offender?(offender)
    offender.welsh_offender == true
  end

  def self.nps_case?(offender)
    offender.case_allocation == NPS
  end

  def self.release_date_gt_10_mths?(offender)
    offender.earliest_release_date >
      DateTime.now.utc.to_date + 10.months
  end

  def self.release_date_gt_15_mths?(offender)
    offender.earliest_release_date >
      WELSH_POLICY_START_DATE + 15.months
  end

  def self.release_date_gt_17_mths_at_policy_date?(offender)
    offender.sentence.earliest_release_date >
      ENGLISH_POLICY_START_DATE + 17.months
  end

  def self.release_date_gt_12_weeks?(offender)
    offender.earliest_release_date >
      DateTime.now.utc.to_date + 12.weeks
  end

  def self.new_case?(offender)
    return true unless offender.sentenced?

    if offender.welsh_offender
      offender.sentence.sentence_start_date > WELSH_POLICY_START_DATE
    else
      offender.sentence_start_date > ENGLISH_POLICY_START_DATE
    end
  end
end

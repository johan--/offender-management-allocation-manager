FactoryBot.define do
  # This object lives in 3 states - eligible, ineligible and discretionary(dont know)
  # The default for this factory is to make the object eligible
  factory :early_allocation do
    oasys_risk_assessment_date do Time.zone.today - 6.months end

    convicted_under_terrorisom_act_2000 do false end
    high_profile do false end
    serious_crime_prevention_order do false end
    mappa_level_3 do false end
    cppc_case do true end
    stage2_validation do false end

    trait :discretionary do
      cppc_case do false end
      extremism_separation do
        false
      end
      high_risk_of_serious_harm do false end
      mappa_level_2 do false end
      pathfinder_process do false end
      other_reason { true }
    end

    trait :ineligible do
      cppc_case do false end
      extremism_separation do
        false
      end
      high_risk_of_serious_harm do false end
      mappa_level_2 do false end
      pathfinder_process do false end
      other_reason { false }
    end

    trait :stage2 do
      stage2_validation do
        true
      end
      extremism_separation do
        false
      end
      high_risk_of_serious_harm do false end
      mappa_level_2 do false end
      pathfinder_process do false end
      other_reason { false }
    end
  end
end
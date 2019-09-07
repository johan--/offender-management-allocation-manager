# frozen_string_literal: true

require_relative '../application_service'

module POMService
  class GetPomNames < ApplicationService
    attr_reader :prison

    def initialize(prison)
      @prison = prison
    end

    def call
      poms_list = POMService::GetPomsForPrison.call(prison)
      poms_list.each_with_object({}) { |p, hsh|
        hsh[p.staff_id] = p.full_name
      }
    end
  end
end
class OverridesController < ApplicationController
  def new
    @prisoner = OffenderService.new.get_offender(params.require(:nomis_offender_id)).data
    @recommended_pom = @prisoner.current_responsibility
    @pom = pom
  end

  def create
    AllocationService.create_override(
      nomis_staff_id: override_params[:nomis_staff_id],
      nomis_offender_id: override_params[:nomis_offender_id],
      override_reason: override_params[:override_reason],
      more_detail: override_reason_params[:more_detail]
      )

    redirect_to allocate_new_path(
      override_params[:nomis_offender_id],
      override_params[:nomis_staff_id]
    )
  end

private

  def pom
    @poms_list ||= PrisonOffenderManagerService.get_poms(caseload)
    @poms_list.select { |p| p.staff_id == params.require(:nomis_staff_id) }.first
  end

  def override_params
    params.require(:override).permit(
      :nomis_offender_id, :nomis_staff_id, :override_reason, :more_detail
    )
  end

  def override_reason_params
    params.permit(:overrides_reason, :more_detail)
  end
end

# frozen_string_literal: true

class EducationHistoryItemController < UserController
  def update
    uehi = current_user.education_history_items.find(params[:id])
    uehi.update!(education_history_item_params)
  end

  private

    def education_history_item_params
      params.require(:education_history_item).permit(:visible_in_profile)
    end
end

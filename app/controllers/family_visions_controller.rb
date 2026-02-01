class FamilyVisionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_colors

  def show
    @vision = @family.vision || @family.build_vision
  end

  def edit
    @vision = @family.vision || @family.build_vision
  end

  def update
    @vision = @family.vision || @family.build_vision
    if @vision.update(vision_params)
      redirect_to family_vision_path(@family), notice: "Family vision updated!"
    else
      render :edit
    end
  end

  private

  def set_colors
    @colors = @family.theme_colors
  end

  def vision_params
    params.require(:family_vision).permit(:mission_statement, :notes, :ten_year_dream)
  end
end

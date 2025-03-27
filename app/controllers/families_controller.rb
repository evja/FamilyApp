class FamiliesController < ApplicationController
  before_action :authenticate_user!

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)
    if @family.save
      current_user.update(family: @family)
      redirect_to @family, notice: "Welcome to your family dashboard!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @family = current_user.family
  end

  def edit
    @family = current_user.family
  end

  def update
    @family = current_user.family
    if @family.update(family_params)
      redirect_to @family, notice: "Family name updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @family = current_user.family
    current_user.update(family: nil)
    @family.destroy
    redirect_to new_family_path, notice: "Family deleted. You can create a new one."
  end

  private

  def family_params
    params.require(:family).permit(:name)
  end
end
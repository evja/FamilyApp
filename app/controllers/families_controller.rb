class FamiliesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to family_path(current_user.family) if current_user.family
  end

  def show
    redirect_to new_family_path unless @family
  end

  def new
    redirect_to family_path(current_user.family) if current_user.family
    @family = Family.new
  end

  def edit
    unless @family.users.include?(current_user)
      redirect_to root_path, alert: 'You do not have permission to edit this family.'
    end
  end

  def create
    @family = Family.new(family_params)

    if @family.save
      current_user.update(family: @family)
      redirect_to @family, notice: 'Family was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    unless @family.users.include?(current_user)
      return redirect_to root_path, alert: 'You do not have permission to update this family.'
    end

    if @family.update(family_params)
      redirect_to @family, notice: 'Family was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    unless @family.users.include?(current_user)
      return redirect_to root_path, alert: 'You do not have permission to delete this family.'
    end

    if @family.users.count > 1
      redirect_to @family, alert: 'Cannot delete family while other users are still members.'
    else
      @family.destroy
      redirect_to root_path, notice: 'Family was successfully deleted.'
    end
  end

  private

  def set_family
    @family = if params[:id]
                Family.find(params[:id])
              else
                current_user.family
              end
  end

  def family_params
    params.require(:family).permit(:name, :theme)
  end
end
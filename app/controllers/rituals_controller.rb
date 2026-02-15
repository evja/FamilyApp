class RitualsController < ApplicationController
  include RoleAuthorization

  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_ritual, only: [:show, :edit, :update, :destroy]
  before_action :require_parent_access!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @rituals = @family.rituals.includes(:components, :family_values).ordered
    @rituals_by_type = @rituals.group_by(&:ritual_type)
    @has_any_rituals = @rituals.exists?
  end

  def show
    @components = @ritual.components.ordered
  end

  def new
    @ritual = @family.rituals.new
    @ritual.components.build(component_type: "perform", position: 0)
    @family_values = @family.family_values.order(:name)
  end

  def create
    @ritual = @family.rituals.new(ritual_params)

    if @ritual.save
      sync_family_values
      redirect_to family_ritual_path(@family, @ritual), notice: "Ritual created successfully."
    else
      @family_values = @family.family_values.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @family_values = @family.family_values.order(:name)
  end

  def update
    if @ritual.update(ritual_params)
      sync_family_values
      redirect_to family_ritual_path(@family, @ritual), notice: "Ritual updated successfully."
    else
      @family_values = @family.family_values.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ritual.destroy
    redirect_to family_rituals_path(@family), notice: "Ritual deleted."
  end

  private

  def set_ritual
    @ritual = @family.rituals.find(params[:id])
  end

  def ritual_params
    params.require(:ritual).permit(
      :name, :description, :ritual_type, :frequency, :purpose, :is_active, :position,
      components_attributes: [:id, :component_type, :title, :description, :duration_minutes, :position, :_destroy]
    )
  end

  def sync_family_values
    value_ids = params[:ritual][:family_value_ids]&.reject(&:blank?)&.map(&:to_i) || []
    @ritual.family_value_ids = value_ids
  end
end

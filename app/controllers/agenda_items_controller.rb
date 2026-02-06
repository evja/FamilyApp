class AgendaItemsController < ApplicationController
  include RoleAuthorization

  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_rhythm
  before_action :set_agenda_item, only: [:edit, :update, :destroy]
  before_action :require_parent_access!

  def new
    @agenda_item = @rhythm.agenda_items.new
    @agenda_item.position = (@rhythm.agenda_items.maximum(:position) || 0) + 1
  end

  def create
    @agenda_item = @rhythm.agenda_items.new(agenda_item_params)
    @agenda_item.position ||= (@rhythm.agenda_items.maximum(:position) || 0) + 1

    if @agenda_item.save
      redirect_to edit_family_rhythm_path(@family, @rhythm), notice: "Agenda item added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @agenda_item.update(agenda_item_params)
      redirect_to edit_family_rhythm_path(@family, @rhythm), notice: "Agenda item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @agenda_item.destroy
    redirect_to edit_family_rhythm_path(@family, @rhythm), notice: "Agenda item removed."
  end

  private

  def set_rhythm
    @rhythm = @family.rhythms.find(params[:rhythm_id])
  end

  def set_agenda_item
    @agenda_item = @rhythm.agenda_items.find(params[:id])
  end

  def agenda_item_params
    params.require(:agenda_item).permit(:title, :instructions, :duration_minutes, :link_type, :position)
  end
end

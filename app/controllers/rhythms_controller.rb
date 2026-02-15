class RhythmsController < ApplicationController
  include RoleAuthorization

  before_action :authenticate_user!
  before_action :authorize_family!
  before_action :set_rhythm, only: [:show, :edit, :update, :destroy, :start, :run, :check_item, :uncheck_item, :finish, :skip]
  before_action :require_parent_access!, only: [:new, :create, :edit, :update, :destroy, :setup, :update_setup]

  def index
    rhythms_base = @family.rhythms.includes(:agenda_items, :completions)
    @overdue_rhythms = rhythms_base.overdue.order(:next_due_at)
    @due_soon_rhythms = rhythms_base.due_soon.order(:next_due_at)
    @on_track_rhythms = rhythms_base.on_track.order(:next_due_at)
    @inactive_rhythms = rhythms_base.inactive.order(:name)
    @has_any_rhythms = @family.rhythms.exists?
  end

  def show
    @recent_completions = @rhythm.completions.completed.recent.limit(5)
    @current_meeting = @rhythm.current_meeting
  end

  def new
    @rhythm = @family.rhythms.new
    @templates = RhythmTemplates.template_list
  end

  def create
    if params[:template_name].present?
      @rhythm = RhythmTemplates.create_from_template(@family, params[:template_name], activate: true)
      if @rhythm
        redirect_to family_rhythm_path(@family, @rhythm), notice: "#{@rhythm.name} created and scheduled."
      else
        redirect_to new_family_rhythm_path(@family), alert: "Template not found."
      end
    else
      @rhythm = @family.rhythms.new(rhythm_params)
      @rhythm.is_active = true
      @rhythm.next_due_at = Time.current + @rhythm.frequency_days.days if @rhythm.next_due_at.nil?

      if @rhythm.save
        # Redirect to edit so they can add agenda items
        redirect_to edit_family_rhythm_path(@family, @rhythm), notice: "Rhythm created! Now add your agenda items below."
      else
        @templates = RhythmTemplates.template_list
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    @templates = RhythmTemplates.template_list
  end

  def update
    if @rhythm.update(rhythm_params)
      redirect_to family_rhythm_path(@family, @rhythm), notice: "Rhythm updated successfully."
    else
      @templates = RhythmTemplates.template_list
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rhythm.destroy
    redirect_to family_rhythms_path(@family), notice: "Rhythm deleted."
  end

  def start
    if @rhythm.current_meeting
      redirect_to run_family_rhythm_path(@family, @rhythm), notice: "Continuing your meeting in progress."
    else
      @rhythm.start_meeting!(current_user)
      redirect_to run_family_rhythm_path(@family, @rhythm), notice: "Meeting started!"
    end
  end

  def run
    @completion = @rhythm.current_meeting
    unless @completion
      redirect_to family_rhythm_path(@family, @rhythm), alert: "No meeting in progress. Start a new meeting first."
      return
    end

    @completion_items = @completion.completion_items.includes(:agenda_item).order("agenda_items.position")
  end

  def check_item
    @completion = @rhythm.current_meeting
    unless @completion
      head :not_found
      return
    end

    item = @completion.completion_items.find_by(id: params[:item_id])
    if item
      item.check!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("completion_item_#{item.id}", partial: "rhythms/completion_item", locals: { item: item, family: @family }),
            turbo_stream.replace("rhythm_actions", partial: "rhythms/rhythm_actions", locals: { completion: @completion, family: @family, rhythm: @rhythm })
          ]
        end
        format.html { redirect_to run_family_rhythm_path(@family, @rhythm) }
      end
    else
      head :not_found
    end
  end

  def uncheck_item
    @completion = @rhythm.current_meeting
    unless @completion
      head :not_found
      return
    end

    item = @completion.completion_items.find_by(id: params[:item_id])
    if item
      item.uncheck!
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("completion_item_#{item.id}", partial: "rhythms/completion_item", locals: { item: item, family: @family }),
            turbo_stream.replace("rhythm_actions", partial: "rhythms/rhythm_actions", locals: { completion: @completion, family: @family, rhythm: @rhythm })
          ]
        end
        format.html { redirect_to run_family_rhythm_path(@family, @rhythm) }
      end
    else
      head :not_found
    end
  end

  def finish
    @completion = @rhythm.current_meeting
    unless @completion
      redirect_to family_rhythm_path(@family, @rhythm), alert: "No meeting in progress."
      return
    end

    @completion.update(notes: params[:notes]) if params[:notes].present?
    @rhythm.complete!(@completion)
    redirect_to family_rhythm_path(@family, @rhythm), notice: "Meeting completed! Next occurrence scheduled for #{@rhythm.next_due_at.strftime('%B %d, %Y')}."
  end

  def skip
    @rhythm.skip!
    redirect_to family_rhythms_path(@family), notice: "#{@rhythm.name} skipped. Next occurrence scheduled for #{@rhythm.next_due_at.strftime('%B %d, %Y')}."
  end

  def setup
    @templates_by_category = RhythmTemplates.templates_by_category
    @category_labels = RhythmTemplates.category_groups
    @existing_rhythm_names = @family.rhythms.pluck(:name)
  end

  def templates
    @templates_by_category = RhythmTemplates.templates_by_category
    @category_labels = RhythmTemplates.category_groups
    @existing_rhythm_names = @family.rhythms.pluck(:name)
  end

  def update_setup
    selected_templates = params[:templates] || []

    selected_templates.each do |template_name|
      next if @family.rhythms.exists?(name: template_name)
      RhythmTemplates.create_from_template(@family, template_name, activate: true)
    end

    if selected_templates.any?
      redirect_to family_rhythms_path(@family), notice: "#{selected_templates.count} rhythm(s) added to your family."
    else
      redirect_to family_rhythms_path(@family), notice: "No rhythms were selected."
    end
  end

  private

  def set_rhythm
    @rhythm = @family.rhythms.find(params[:id])
  end

  def rhythm_params
    params.require(:rhythm).permit(
      :name, :description, :frequency_type, :frequency_days, :rhythm_category, :is_active,
      agenda_items_attributes: [:id, :position, :title, :duration_minutes, :instructions, :link_type, :_destroy]
    )
  end
end

class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_family!

  def index
    @members = @family.members
  end

  def show
    @member = @family.members.find(params[:id])
  end

  def new
    @member = @family.members.new
  end

  def create
    @member = @family.members.new(member_params)
    if @member.save
      redirect_to family_members_path(@family), notice: "Member added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @member = @family.members.find(params[:id])
  end

  def update
    @member = @family.members.find(params[:id])
    if @member.update(member_params)
      redirect_to family_member_path(@family, @member), notice: "Member updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member = @family.members.find(params[:id])
    @member.destroy
    redirect_to family_members_path(@family), notice: "Member deleted."
  end

  private

  def member_params
    params.require(:member).permit(:name, :age, :personality, :interests, :health, :development, :needs, :is_parent)
  end
end

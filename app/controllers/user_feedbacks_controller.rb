class UserFeedbacksController < ApplicationController
  before_action :gold_only, :only => [:new, :edit, :create, :update, :destroy]
  before_action :check_no_feedback, only: [:new, :edit, :create, :update, :destroy]
  respond_to :html, :xml, :json

  def new
    @user_feedback = UserFeedback.new(user_feedback_params(:create))
    respond_with(@user_feedback)
  end

  def edit
    @user_feedback = UserFeedback.visible.find(params[:id])
    check_privilege(@user_feedback)
    respond_with(@user_feedback)
  end

  def show
    @user_feedback = UserFeedback.visible.find(params[:id])
    respond_with(@user_feedback)
  end

  def index
    @user_feedbacks = UserFeedback.visible.includes(:user, :creator).paginated_search(params, count_pages: true)
    respond_with(@user_feedbacks)
  end

  def create
    @user_feedback = UserFeedback.create(user_feedback_params(:create))
    respond_with(@user_feedback)
  end

  def update
    @user_feedback = UserFeedback.visible.find(params[:id])
    check_privilege(@user_feedback)
    @user_feedback.update(user_feedback_params(:update))
    respond_with(@user_feedback)
  end

  def destroy
    @user_feedback = UserFeedback.visible.find(params[:id])
    check_privilege(@user_feedback)
    @user_feedback.destroy
    respond_with(@user_feedback)
  end

  private

  def check_privilege(user_feedback)
    raise User::PrivilegeError unless user_feedback.editable_by?(CurrentUser.user)
  end

  def check_no_feedback
    if CurrentUser.no_feedback?
      raise User::PrivilegeError
    end
  end

  def user_feedback_params(context)
    permitted_params = %i[body category]
    permitted_params += %i[user_id user_name] if context == :create

    params.fetch(:user_feedback, {}).permit(permitted_params)
  end
end

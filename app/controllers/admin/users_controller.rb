# app/controllers/admin/users_controller.rb
class Admin::UsersController < Admin::ApplicationController
  before_action :set_user, only: %i(show toggle_status)

  # GET /admin/users
  def index
    @q = User.where(role: :user).ransack(params[:q])
    @pagy, @users = pagy(@q.result(distinct: true).order(created_at: :desc))
  end

  # GET /admin/users/:id
  def show
    @pagy, @borrow_requests = pagy(@user.borrow_requests.sorted)
  end

  # PATCH /admin/users/:id/toggle_status
  def toggle_status
    toggle_user_status
    respond_to do |format|
      format.html do
        redirect_to admin_users_path,
                    notice: flash[:notice] || flash[:alert]
      end
      format.turbo_stream
    end
  end

  private

  def toggle_user_status
    @user.active? ? @user.inactive! : @user.active!
    flash.now[:notice] = t(".update_success")
  rescue StandardError => e
    Rails.logger.error("Toggle status failed: #{e.message}")
    flash.now[:alert] = t(".update_fail")
  end

  def set_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:alert] = t("admin.users.flash.not_found")
    redirect_to users_path
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end
end

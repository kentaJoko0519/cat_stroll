class Public::UsersController < ApplicationController
  before_action :authenticate_user!

# ユーザー一覧
  def index
    @users=User.all
  end

# ユーザー詳細
  def show
    @user=User.find(params[:id])
  end
  
# 退会確認
  def unsubscribe
    @user=current_user
  end

# 退会処理
  def withdraw
    @user=current_user
    # is_deletedカラムをtrueに変更することにより削除フラグを立てる
    @user.update(is_deleted: true)
    reset_session
    flash[:notice] = "退会処理を実行いたしました"
    redirect_to root_path
  end

# マイページ
  def my_page
    # @user→ログインしているユーザーの情報
    @user=current_user
  end

# 登録情報編集画面
  def edit
    # @user→ログインしているユーザーの情報
    @user=current_user
  end

# 登録情報編集
  def update
    @user=current_user
    @user.update(user_params)
    redirect_to my_page_path
  end

  private
  def user_params
    params.require(:user).permit(:first_name,:last_name,:first_name_kana,:last_name_kana, :email, :profile_image, :introduction)
  end

end

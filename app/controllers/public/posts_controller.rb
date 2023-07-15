class Public::PostsController < ApplicationController

# ユーザー側  投稿
  # index,showアクション以外は新規登録orログインしないとアクションが実行されない
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  def new
    @post = Post.new
    # session[:locate_params]=
  end

  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id

    if @post.save
      flash[:notice] = "投稿完了"
      redirect_to post_path(@post.id)
    else
      @messages = @post.errors.messages
      flash[:alert] = @messages[:introduction].join("") + @messages[:images].join("")
      redirect_to request.referer
    end
  end

  def index
    @posts = Post.all
    # 検索機能
    # if user_signed_in?
    if params[:search].present?             # 検索のフォームに何か検索ワードが入っていたら
      # 投稿のタグから探す
      tag_posts = @posts.joins(:tags).distinct.where('tags.name like ?', "%#{params[:search]}%")
      # 投稿者を探す
      posts = @posts.joins(:user).where('posts.name like ?', "%#{params[:search]}%").or(
              # ↓ address を検索に入れることにより、地名で検索できるようにする
              @posts.joins(:user).where('posts.address like ?', "%#{params[:search]}%")).or(
              @posts.joins(:user).where('users.user_name like ?', "%#{params[:search]}%"))
      # tag_posts と posts で重複しないように uniq を設定
      @posts = (tag_posts + posts).uniq
    end

    # 検索結果がなかった場合
    if params[:search].present? && @posts.count == 0
      flash[:alert] = "検索結果がありません"
      render :index
    end
    flash[:alert] = nil
  end

  def show
    @post = Post.find(params[:id])
    @post.split_text
    @user = @post.user
    # コメント機能
    @comments = @post.comments                #投稿詳細に関連付けてあるコメントを全取得
    @comment = Comment.new                    # コメントの空のインスタンスを生成
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      flash[:notice] = "更新しました"
      redirect_to post_path(@post.id)
    else
      render :edit
    end
  end

  def destroy
    post = Post.find(params[:id])
    post.destroy
    flash[:notice] = "投稿を削除しました"
    redirect_to posts_path
  end

  private
  def post_params
    params.require(:post).permit(:user_id, :name, :address, :latitude, :longitude, :introduction, images: [])
  end

end

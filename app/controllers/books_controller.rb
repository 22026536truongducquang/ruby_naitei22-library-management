class BooksController < ApplicationController
  before_action :set_book,
                only: %i(show borrow add_to_favorite remove_from_favorite
write_a_review)
  before_action :set_recommended_books, only: :show
  before_action :set_review_stats, only: :show
  before_action :set_reviews, only: :show
  before_action :load_favorite, only: %i(add_to_favorite remove_from_favorite)

  # GET /books/:id
  def show
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "reviews",
          partial: "books/reviews",
          locals: {pagy_reviews: @pagy_reviews, reviews: @reviews}
        )
      end
    end
  end

  # POST /books/:id/borrow
  def borrow; end

  # POST /books/:id/add_to_favorite
  def add_to_favorite
    @favorite ||= current_user.favorites.new(favorable: @book)

    respond_to do |format|
      if @favorite.save
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "favorite_button_#{@book.model_name.singular}_#{@book.id}",
            partial: "books/favorite_button",
            locals: {item: @book}
          )
        end
        format.html {redirect_to @book, notice: t(".favorite_success")}
      else
        format.html {redirect_to @book, alert: t(".favorite_failed")}
      end
    end
  end

  # DELETE /books/:id/remove_from_favorite
  def remove_from_favorite
    respond_to do |format|
      if @favorite.nil?
        format.html {redirect_to @book, alert: t(".favorite_not_found")}
      elsif @favorite.destroy
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "favorite_button_#{@book.model_name.singular}_#{@book.id}",
            partial: "books/favorite_button",
            locals: {item: @book}
          )
        end
        format.html {redirect_to @book, notice: t(".unfavorite_success")}
      else
        format.html {redirect_to @book, alert: t(".unfavorite_failed")}
      end
    end
  end

  # POST /books/:id/write_a_review
  def write_a_review; end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def set_recommended_books
    books_by_author = Book.by_author(@book.author_id).exclude_book(@book.id)
    @pagy_books, @recommended_books = pagy(
      books_by_author,
      items: Settings.digits.digit_6,
      page_param: :recommended_page,
      overflow: :last_page
    )
  end

  def set_review_stats
    @review_counts = @book.reviews.group(:score).count
    @total_reviews = @book.reviews.count
  end

  def set_reviews
    @pagy_reviews, @reviews = pagy(
      @book.reviews.includes(:user).order(created_at: :desc),
      items: Settings.digits.digit_5,
      page_param: :reviews_page,
      overflow: :last_page
    )
  end

  def load_favorite
    @favorite = current_user.favorites.find_by(favorable: @book)
  end
end

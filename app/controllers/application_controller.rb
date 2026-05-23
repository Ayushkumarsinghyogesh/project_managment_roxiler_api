class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound,   with: :not_found
  rescue_from ActiveRecord::RecordInvalid,    with: :unprocessable
  rescue_from Pundit::NotAuthorizedError,     with: :forbidden
  rescue_from AuthenticationError,            with: :unauthorized

  private

  def authenticate_user!
    header = request.headers["Authorization"]
    raise AuthenticationError, "Missing Authorization header." if header.blank?

    token   = header.split(" ").last
    payload = JwtService.decode(token)
    @current_user = User.find(payload[:user_id])
  rescue ActiveRecord::RecordNotFound
    raise AuthenticationError, "User not found."
  end

  def current_user
    @current_user
  end

  # ── Error response helpers ────────────────────────────────────────────

  def not_found(err)
    render json: { error: err.message }, status: :not_found
  end

  def unprocessable(err)
    render json: { errors: err.record.errors.full_messages }, status: :unprocessable_entity
  end

  def forbidden
    render json: { error: "You are not authorized to perform this action." }, status: :forbidden
  end

  def unauthorized(err)
    render json: { error: err.message }, status: :unauthorized
  end

  # Shared pagination meta helper
  def pagination_meta(collection)
    {
      current_page:  collection.current_page,
      total_pages:   collection.total_pages,
      total_count:   collection.total_count,
      per_page:      collection.limit_value
    }
  end
end

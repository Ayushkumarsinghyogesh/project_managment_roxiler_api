module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[login register]

      # POST /api/v1/auth/register
      def register
        user = User.new(register_params)
        user.save!
        token = JwtService.encode(user_id: user.id)

        render json: {
          message: "Account created successfully.",
          token:   token,
          user:    UserBlueprint.render_as_hash(user)
        }, status: :created
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email]&.downcase)

        unless user&.authenticate(params[:password])
          return render json: { error: "Invalid email or password." }, status: :unauthorized
        end

        token = JwtService.encode(user_id: user.id)

        render json: {
          message: "Logged in successfully.",
          token:   token,
          user:    UserBlueprint.render_as_hash(user)
        }
      end

      # GET /api/v1/auth/me
      def me
        render json: { user: UserBlueprint.render_as_hash(current_user) }
      end

      private

      def register_params
        params.permit(:name, :email, :password, :password_confirmation, :role)
      end
    end
  end
end

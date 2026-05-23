module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :set_project, only: %i[show update destroy]

      # GET /api/v1/projects
      def index
        projects = policy_scope(Project)
                     .with_full_details
                     .order(created_at: :desc)
                     .page(params[:page])
                     .per(params[:per_page] || 10)

        render json: {
          projects:   ProjectBlueprint.render_as_hash(projects, view: :with_tasks),
          pagination: pagination_meta(projects)
        }
      end

      # GET /api/v1/projects/:id
      def show
        authorize @project
        render json: { project: ProjectBlueprint.render_as_hash(@project, view: :with_tasks) }
      end

      # POST /api/v1/projects
      def create
        authorize Project
        project = Project.new(project_params)
        project.save!
        render json: {
          message: "Project created.",
          project: ProjectBlueprint.render_as_hash(project.reload, view: :with_tasks)
        }, status: :created
      end

      # PATCH /api/v1/projects/:id
      def update
        authorize @project
        @project.update!(project_params)
        render json: {
          message: "Project updated.",
          project: ProjectBlueprint.render_as_hash(@project.reload, view: :with_tasks)
        }
      end

      # DELETE /api/v1/projects/:id
      def destroy
        authorize @project
        @project.destroy!
        render json: { message: "Project deleted." }
      end

      private

      def set_project
        @project = Project.with_full_details.find(params[:id])
      end

      def project_params
        params.permit(:name, :description, :status, :manager_id)
      end
    end
  end
end

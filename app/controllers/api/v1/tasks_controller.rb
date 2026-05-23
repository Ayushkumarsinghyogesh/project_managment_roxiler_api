module Api
  module V1
    class TasksController < ApplicationController
      before_action :set_task, only: %i[show update destroy]

      # GET /api/v1/tasks
      def index
        tasks = policy_scope(Task)
                  .includes(:project, :assignee)
                  .by_status(params[:status])
                  .by_assignee(params[:assignee_id])
                  .by_project(params[:project_id])
                  .sorted_by(params[:sort_by], params[:sort_dir])
                  .page(params[:page])
                  .per(params[:per_page] || 15)

        render json: {
          tasks:      TaskBlueprint.render_as_hash(tasks, view: :with_associations),
          pagination: pagination_meta(tasks)
        }
      end

      # GET /api/v1/tasks/:id
      def show
        authorize @task
        render json: { task: TaskBlueprint.render_as_hash(@task, view: :with_associations) }
      end

      # POST /api/v1/tasks
      def create
        task = Task.new(task_params)
        authorize task   # policy checks manager ownership

        task.save!
        task.reload

        render json: {
          message: "Task created.",
          task:    TaskBlueprint.render_as_hash(task, view: :with_associations)
        }, status: :created
      end

      # PATCH /api/v1/tasks/:id
      def update
        authorize @task
        @task.update!(task_params)
        render json: {
          message: "Task updated.",
          task:    TaskBlueprint.render_as_hash(@task.reload, view: :with_associations)
        }
      end

      # DELETE /api/v1/tasks/:id
      def destroy
        authorize @task
        @task.destroy!
        render json: { message: "Task deleted." }
      end

      private

      def set_task
        @task = Task.includes(:project, :assignee).find(params[:id])
      end

      def task_params
        params.permit(:title, :status, :priority, :due_date, :project_id, :assignee_id)
      end
    end
  end
end

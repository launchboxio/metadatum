# frozen_string_literal: true

module Api
  module V1
    class MetadataController < Api::ApiController
      before_action :load_context

      # Search for any metadata stored for this project
      def index
        where = params.slice(:ref, :workflow, :event_name, :ref_type)
        @metadata = Metadatum
                    .where(repository: @repository)
                    .where(where).all
        render json: @metadata
      end

      # Get specific metadata object
      def show
        @metadata = Metadatum.where(repository: @repository)
        # TODO: Handle not found records nicer
        render json: @metadata.where(id: params[:id]).first!
      end

      # Store new metadata for an object
      def create
        params = create_params
        @metadatum = Metadatum.new(params)
        @metadatum.data = request.raw_post
        @metadatum.save!
      end

      # Update a single record
      # NOTE: This really functions the same as an upsert. We're not in the
      # business of managing pieces of the data blob
      def update
        params = create_params
        @metadatum = Metadatum.new(params)
        @metadatum.data = request.raw_post
        @metadatum.save!
      end

      def destroy
        @metadata = Metadatum
                    .where(repository: @repository)
                    .where(id: params[:id]).first!
        raise ActionController::RoutingError, 'Not Found' if @metadata.nil?

        @metadata.destroy!
      end

      private

      def load_context
        @context = request.env['context']
        @repository = request.env['repository']
      end

      def create_params
        @context.slice(
          'sub', 'ref', 'sha', 'repository',
          'repository_owner', 'repository_owner_id', 'run_id',
          'repository_visibility', 'repository_id', 'actor_id',
          'actor', 'workflow', 'head_ref', 'base_ref', 'event_name',
          'ref_type', 'workflow_ref', 'workflow_sha', 'job_workflow_ref',
          'job_workflow_sha', 'runner_environment', 'iss'
        )
      end
    end
  end
end

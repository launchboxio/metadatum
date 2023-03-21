# frozen_string_literal: true

module Api
  module V1
    class MetadataController < Api::ApiController
      before_action :verify_token

      # Search for any metadata stored for this project
      def index
        where = params.slice(:ref, :workflow, :event_name, :ref_type)
        @metadata = Metadatum
                    .where(repository: @context[0]['repository'])
                    .where(where).all
        render json: @metadata
      end

      # Get specific metadata object
      def show
        @metadata = Metadatum.where(repository: @context[0]['repository'])
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
                    .where(repository: @context[0]['repository'])
                    .where(id: params[:id]).first!
        raise ActionController::RoutingError, 'Not Found' if @metadata.nil?

        @metadata.destroy!
      end

      private

      def verify_token
        token = request.headers['Authorization'].split(' ').last
        @context = JWT.decode(token, nil, true, { algorithms: ['RS256'], jwks: jwks_loader })
      end

      def create_params
        @context[0].slice(
          'sub', 'ref', 'sha', 'repository',
          'repository_owner', 'repository_owner_id', 'run_id',
          'repository_visibility', 'repository_id', 'actor_id',
          'actor', 'workflow', 'head_ref', 'base_ref', 'event_name',
          'ref_type', 'workflow_ref', 'workflow_sha', 'job_workflow_ref',
          'job_workflow_sha', 'runner_environment', 'iss'
        )
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def jwks_loader = lambda do |options|
        if options[:kid_not_found] && @cache_last_update < Time.now.to_i - 300
          logger.info("Invalidating JWK cache. #{options[:kid]} not found from previous cache")
          @cached_keys = nil
        end
        @cached_keys ||= begin
          @cache_last_update = Time.now.to_i
          jwks = JWT::JWK::Set.new(JSON.parse(github_jwks_hash.body))
          jwks.select! { |key| key[:use] == 'sig' } # Signing Keys only
          jwks
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def github_jwks_hash
        Net::HTTP.get_response(
          URI('https://token.actions.githubusercontent.com/.well-known/jwks')
        )
      end
    end
  end
end

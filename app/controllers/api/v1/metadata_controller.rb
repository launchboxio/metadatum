class Api::V1::MetadataController < Api::ApiController
  before_action :load_token

  # Search for any metadata stored for this project
  def index
    @metadata = Metadatum.where(repository: @context[0]['repository'])
    @metadata.where(ref: params[:ref]) if params[:ref]
    @metadata.where(workflow: params[:workflow]) if params[:workflow]
    @metadata.where(event_name: params[:event_name]) if params[:event_name]
    @metadata.where(ref_type: params[:ref_type]) if params[:ref_type]

    # TODO: Support filtering for specific values in .data
    render json: @metadata.limit(100).all
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
    @metadatum.save!
  end

  # Update a single record
  # NOTE: This really functions the same as an upsert. We're not in the
  # business of managing pieces of the data blob
  def update
    params = create_params
    @metadatum = Metadatum.new(params)
    @metadatum.save!
  end

  def destroy
    @metadata = Metadatum.
      where(repository: @context[0]['repository']).
      where(id: params[:id]).first!
    raise ActionController::RoutingError.new('Not Found') if @metadata.nil?
    @metadata.destroy!
  end

  private

  def load_token
    token = request.headers['Authorization'].split(' ').last
    @context = JWT.decode token, nil, false
  end

  # TODO: Validate Github OIDC tokens using their public signing key
  def load_public_keys(issuer, kid)
    Rails.cache.fetch("#{issuer}-#{kid}", expires_in: 1.hour) do
      res = Net::HTTP.get_response(URI("#{issuer}/.well-known/jwks"))
      key = res['keys'].select { |record| record.kid == kid }.first
      key if key.not nil
    end
  end

  def create_params
    @context[0].slice(
      'sub',
      'ref',
      'sha',
      'repository',
      'repository_owner',
      'repository_owner_id',
      'run_id',
      'repository_visibility',
      'repository_id',
      'actor_id',
      'actor',
      'workflow',
      'head_ref',
      'base_ref',
      'event_name',
      'ref_type',
      'workflow_ref',
      'workflow_sha',
      'job_workflow_ref',
      'job_workflow_sha',
      'runner_environment',
      'iss'
    )
  end
end
class CreateMetadata < ActiveRecord::Migration[7.0]
  def change
    create_table :metadata do |t|
      t.string :sub
      t.string :ref
      t.string :sha
      t.string :repository
      t.string :repository_owner
      t.integer :repository_owner_id
      t.bigint :run_id
      t.string :repository_visibility
      t.bigint :repository_id
      t.bigint :actor_id
      t.string :actor
      t.string :workflow
      t.string :head_ref
      t.string :base_ref
      t.string :event_name
      t.string :ref_type
      t.string :workflow_ref
      t.string :workflow_sha
      t.string :job_workflow_ref
      t.string :job_workflow_sha
      t.string :runner_environment
      t.string :iss

      t.json :data
      t.timestamps
    end
  end
end

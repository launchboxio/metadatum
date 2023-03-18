# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/AbcSize
class CreateMetadata < ActiveRecord::Migration[7.0]
  def change
    create_table :metadata do |t|
      t.string :sub
      t.string :ref, index: true
      t.string :sha, index: true
      t.string :repository, index: true
      t.string :repository_owner
      t.integer :repository_owner_id
      t.bigint :run_id
      t.string :repository_visibility
      t.bigint :repository_id
      t.bigint :actor_id
      t.string :actor
      t.string :workflow, index: true
      t.string :head_ref
      t.string :base_ref
      t.string :event_name, index: true
      t.string :ref_type, index: true
      t.string :workflow_ref
      t.string :workflow_sha
      t.string :job_workflow_ref
      t.string :job_workflow_sha
      t.string :runner_environment
      t.string :iss

      t.text :data
      t.timestamps
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize

# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:events) do
      add_column :additional_notes, String
    end
  end
end

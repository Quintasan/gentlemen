# frozen_string_literal: true

Sequel.migration do
  change do
    create_table?(:events) do
      primary_key :id
      String :city
      String :place
      String :address
      Time :time
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

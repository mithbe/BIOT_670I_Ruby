class AddGinIndexesToDandelionTables < ActiveRecord::Migration[8.0]
  def up
    # Enable pg_trgm if not already enabled
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    # --- dandelions ---
    add_column :dandelions, :search_vector, :tsvector unless column_exists?(:dandelions, :search_vector)
    execute <<~SQL
      UPDATE dandelions
      SET search_vector = to_tsvector('english',
        coalesce(species,'') || ' ' || coalesce(location,'')
      );
    SQL
    add_index :dandelions, :search_vector, using: :gin unless index_exists?(:dandelions, :search_vector)
    execute <<~SQL
      DROP TRIGGER IF EXISTS dandelions_tsvector_update ON dandelions;
      CREATE TRIGGER dandelions_tsvector_update
      BEFORE INSERT OR UPDATE ON dandelions
      FOR EACH ROW EXECUTE FUNCTION
      tsvector_update_trigger('search_vector', 'pg_catalog.english', 'species', 'location');
    SQL

    # --- file_records (JSONB columns) ---
    change_column :file_records, :tags, :jsonb, using: "tags::jsonb" unless column_exists?(:file_records, :tags, :jsonb)
    change_column :file_records, :metadata, :jsonb, using: "metadata::jsonb" unless column_exists?(:file_records, :metadata, :jsonb)
    add_index :file_records, :tags, using: :gin unless index_exists?(:file_records, :tags)
    add_index :file_records, :metadata, using: :gin unless index_exists?(:file_records, :metadata)

    # --- metadata ---
    add_column :metadata, :search_vector, :tsvector unless column_exists?(:metadata, :search_vector)
    execute <<~SQL
      UPDATE metadata
      SET search_vector = to_tsvector('english',
        coalesce(key,'') || ' ' || coalesce(value,'')
      );
    SQL
    add_index :metadata, :search_vector, using: :gin unless index_exists?(:metadata, :search_vector)
    execute <<~SQL
      DROP TRIGGER IF EXISTS metadata_tsvector_update ON metadata;
      CREATE TRIGGER metadata_tsvector_update
      BEFORE INSERT OR UPDATE ON metadata
      FOR EACH ROW EXECUTE FUNCTION
      tsvector_update_trigger('search_vector', 'pg_catalog.english', 'key', 'value');
    SQL

    # --- userinfos ---
    add_column :userinfos, :search_vector, :tsvector unless column_exists?(:userinfos, :search_vector)
    execute <<~SQL
      UPDATE userinfos
      SET search_vector = to_tsvector('english',
        coalesce(first_name,'') || ' ' || coalesce(last_name,'') || ' ' ||
        coalesce(address,'') || ' ' || coalesce(city,'') || ' ' ||
        coalesce(state,'') || ' ' || coalesce(zip_code,'')
      );
    SQL
    add_index :userinfos, :search_vector, using: :gin unless index_exists?(:userinfos, :search_vector)
    execute <<~SQL
      DROP TRIGGER IF EXISTS userinfos_tsvector_update ON userinfos;
      CREATE TRIGGER userinfos_tsvector_update
      BEFORE INSERT OR UPDATE ON userinfos
      FOR EACH ROW EXECUTE FUNCTION
      tsvector_update_trigger('search_vector', 'pg_catalog.english', 'first_name', 'last_name', 'address', 'city', 'state', 'zip_code');
    SQL
  end

  def down
    # --- dandelions ---
    remove_index :dandelions, :search_vector if index_exists?(:dandelions, :search_vector)
    remove_column :dandelions, :search_vector if column_exists?(:dandelions, :search_vector)
    execute "DROP TRIGGER IF EXISTS dandelions_tsvector_update ON dandelions;"

    # --- file_records ---
    remove_index :file_records, :tags if index_exists?(:file_records, :tags)
    remove_index :file_records, :metadata if index_exists?(:file_records, :metadata)

    # --- metadata ---
    remove_index :metadata, :search_vector if index_exists?(:metadata, :search_vector)
    remove_column :metadata, :search_vector if column_exists?(:metadata, :search_vector)
    execute "DROP TRIGGER IF EXISTS metadata_tsvector_update ON metadata;"

    # --- userinfos ---
    remove_index :userinfos, :search_vector if index_exists?(:userinfos, :search_vector)
    remove_column :userinfos, :search_vector if column_exists?(:userinfos, :search_vector)
    execute "DROP TRIGGER IF EXISTS userinfos_tsvector_update ON userinfos;"
  end
end


require 'active_support/all'
require 'logger'
require 'sequel'

### data ######################################################################

DB_PROJECT_DIR = Pathname(__FILE__).join('../../..')


### sequel ####################################################################

def database_name
    ENV['CIDER_CI_TEST_DATABASE'].presence ||
    ENV['PGDATABASE'].presence ||
    'cider-ci'
end

def database_user
  ENV['CIDER_CI_DATABASE_USER'].presence ||
    ENV['PGUSER'].presence ||
    'cider-ci'
end

def database_password
  ENV['CIDER_CI_DATABASE_PASSWORD'].presence ||
    ENV['PGPASSWORD'].presence ||
    'cider-ci'
end

def database_host
  ENV['CIDER_CI_DATABASE_HOST'].presence ||
    ENV['PGHOST'].presence ||
    'localhost'
end

def database_port
  Integer(
    ENV['CIDER_CI_DATABASE_PORT'].presence ||
    ENV['PGPORT'].presence ||
    5415)
end

def database
  @database ||= Sequel.postgres(
    database: database_name,
    user: database_user,
    password: database_password,
    host: database_host ,
    port: database_port)
end

database.extension :pg_json
database.wrap_json_primitives = true


### helpers ###################################################################



def db_clean
  tables = database[ <<-SQL.strip_heredoc
    SELECT table_name
      FROM information_schema.tables
    WHERE table_type = 'BASE TABLE'
    AND table_schema = 'public'
    ORDER BY table_type, table_name;
  SQL
  ].map{|r| r[:table_name]}.reject { |tn| tn == 'schema_migrations' } \
    .join(', ').tap do |tables|
      database.run" TRUNCATE TABLE #{tables} CASCADE; "
    end
end


def db_restore_data data
  database.transaction do
    # pg_dumps reset the search_path for the current session
    # we restore it to the setting before the dump was restored
    search_path = database[
      "SELECT setting FROM pg_settings WHERE name = 'search_path'"
    ].first[:setting]
    database.run \
      'SET session_replication_role = REPLICA;'  \
      <<  data \
      << 'SET session_replication_role = DEFAULT;' \
      << "SET search_path = #{search_path}";
  end
end


def db_with_disabled_triggers
  database.run 'SET session_replication_role = REPLICA;'
  result = yield
  database.run 'SET session_replication_role = DEFAULT;'
  result
end

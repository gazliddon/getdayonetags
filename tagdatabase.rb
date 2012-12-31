# ---------------------------------------------------------------------------------------------------------------------
# Persistent database storing information about what I've already sent to OF
require 'Sequel'

class TagDatabase

  def initialize
    db_file ='out/test.db'
    exists = File.exists?  db_file
    @db = Sequel.sqlite(db_file)
    create_tables unless exists
  end

  def in_database? file_name, md5
    f = @db[:files].first(:md5 => md5)
    if f
      f[:file] == file_name
    else
      false
    end
  end

  def add_to_database file_name, md5
    t = @db[:files]
    t.insert :file => file_name, :md5 => md5
  end

  def find_file file_name
    @db[:files].first(:file => file_name)
  end

  # Database schema
  def create_tables
    @db.create_table :files do
      primary_key :id
      String :file, :size => 4096
      String :md5
    end
  end
end # class TagDatabase

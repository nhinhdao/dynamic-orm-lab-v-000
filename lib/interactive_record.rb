require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
    #1. table_name
    def self.table_name
        self.to_s.downcase.pluralize
    end
    #2. column_names
    def self.column_names
        DB[:conn].execute("pragma table_info('#{table_name}')").map { |row|  row['name']}.compact
    end
    #table_name_for_insert
    def table_name_for_insert
        self.class.table_name
    end
    #3. col_names_for_insert
    def col_names_for_insert
        self.class.column_names.delete_if{|name| name == 'id'}.join(", ")
    end
    #4. values_for_insert
    def values_for_insert
        values = []
        self.class.column_names.each {|col_name| values << "'#{send(col_name)}'" unless send(col_name).nil?}
        values.join(", ")
    end
    #5. save method
    def save
        sql = "insert into #{table_name_for_insert} (#{col_names_for_insert}) values (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("select last_insert_rowid() from #{table_name_for_insert}")[0][0]
    end
    #6. 2find_by_name
    def self.find_by_name(name)
        sql = "select * from #{table_name} where name = ?"
        DB[:conn].execute(sql, name)
    end
    #7. find_by
    def self.find_by(attribute)
    end

end

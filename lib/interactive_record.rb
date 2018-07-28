require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end


    def self.column_names
        DB[:conn].execute("pragma table_info('#{table_name}')").map { |row|  row['name']}.compact
    end


    def initialize(options ={})
        options.each {|key, value| self.send("#{key}=", value)}
    end


    def table_name_for_insert
        self.class.table_name
    end


    def col_names_for_insert
        self.class.column_names.delete_if{|name| name == 'id'}.join(", ")
    end


    def values_for_insert
        self.class.column_names.map {|col_name| '#{send(col_name)}' unless send(col_name).nil?}.join(", ")
    end


    def save
        sql = "insert into #{table_name_for_insert} (#{col_names_for_insert}) values (#{values_for_insert})"
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("select last_insert_rowid() from #{table_name_for_insert}")[0][0]
    end


    def self.find_by_name(name)
        sql = "select * from #{self.table_name} where name = ?"
        DB[:conn].execute(sql, name)
    end


    def self.find_by(hash)
        sql = "select * from #{self.table_name} where #{hash.flatten[0]} = '#{hash.flatten[1]}'"
        DB[:conn].execute(sql)
    end
end

CSV_FILE = './au_example.csv'

require 'rubygems'
gem 'activerecord'
require 'yaml'
require 'active_record'
require 'csv'

require File.join('.', 'intierra_reader.rb')
require File.join('.', 'connection.rb')
require File.join('./lib', 'entity.rb')
require File.join('./lib', 'deposit.rb')

intierra = IntierraReader.new(CSV_FILE)

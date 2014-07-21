dbconfig = YAML::load(File.open('database.yml'))

ActiveRecord::Base.establish_connection(dbconfig["test"])

ActiveRecord::Base.connection.execute("ALTER SESSION set NLS_DATE_FORMAT ='DD-MON-FXYYYY'")
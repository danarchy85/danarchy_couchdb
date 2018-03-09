
module DanarchyCouchDB::ConfigManager
  class CouchDB
    def initialize(account)
      @account = account
    end
    
    def new_cdb_connection
      if @account[:couchdb]
        print "A CouchDB connection already exists. Should we overwrite it? (Y/n): "
        answer = gets.chomp
        if answer =~ /^n(o)?$/i
          puts "Keeping existing CouchDB Connection."
          return @account
        end
      elsif answer =~ /^y(es)?$/i
        puts "Removing existing CouchDB connection."
        @account.delete(:couchdb)
      end

      print "CouchDB Hostname: "
      hostname = gets.chomp
      print 'CouchDB Username: '
      username = gets.chomp
      print 'CouchDB Password: '
      password = gets.chomp
      print 'CouchDB Database: '
      database = gets.chomp
      print 'Enable SSL? (Y/n): '
      ssl  = gets.chomp
      port = nil

      if ssl =~ /^y(es)?$/i || ssl.empty?
        ssl = true
        port = '6984'
      else
        ssl = false
        port = '5984'
      end
      
      add_couchdb(@account, hostname, username, password, database, port, ssl)
      @account
    end

    def verify_connection(couchdb)
      cdb = DanarchyCouchDB::Connection.new(couchdb)
      cdb.get('')
    end

    private
    def add_couchdb(account, hostname, username, password, database, port, ssl)
      couchdb = { hostname: hostname,
                  username: username,
                  password: password,
                  database: database,
                  port:     port,
                  ssl:      ssl }

      verify = verify_connection(couchdb)

      if verify[:error]
        puts "Failed to connect to: #{couchdb[:hostname]}:#{couchdb[:port]}! Not adding this connection."
        return false
      elsif verify[:couchdb] == 'Welcome'
        puts "Adding CouchDB connection to: #{couchdb[:hostname]}:#{couchdb[:port]}."
        @account[:couchdb] = couchdb
      end
    end

    def delete_couchdb
      @account.delete(:couchdb)
    end
  end  
end

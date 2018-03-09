require 'danarchy_couchdb/version'
require 'danarchy_couchdb/config_manager'
require 'json'
require 'net/http'

module DanarchyCouchDB
  class Connection
    def initialize(connection)
      @connection = connection
      uri = 'http' if !@connection[:ssl]
      uri = 'https' if @connection[:ssl]
      @uri = "#{uri}://#{connection[:hostname]}:#{connection[:port]}"
    end

    def get(*args)
      database = args.shift
      document = args.shift
      revision = args.shift
      
      uri  = "#{@uri}/#{database}"
      uri += "/#{document}"        if document
      uri += "/?rev=#{revision}"   if revision

      uri = URI.parse(URI.encode(uri))
      JSON.parse(request(Net::HTTP::Get.new(uri)), symbolize_names: true)
    end

    def get_attachment(database, document, attachment)
      uri  = "#{@uri}/#{database}/#{document}/#{attachment}"
      uri = URI.parse(URI.encode(uri))
      request(Net::HTTP::Get.new(uri))
    end

    def put(*args)
      database = args.shift
      document = args.shift
      data     = args.shift
      
      uri  = "#{@uri}/#{database}"
      uri += "/#{document}" if document

      uri = URI.parse(URI.encode("#{@uri}/#{database}/#{document}"))
      req = Net::HTTP::Put.new(uri)
      req["content-type"] = "application/json"
      req.body = data.to_json if data
      JSON.parse(request(req), symbolize_names: true)
    end

    def put_attachment(*args)
      database   = args.shift
      document   = args.shift
      revision   = args.shift
      attachment = args.shift
      data       = args.shift
      type       = args.shift
      
      uri  = "#{@uri}/#{database}/#{document}/#{attachment}?rev=#{revision}"
      uri = URI.parse(URI.encode(uri))
      req = Net::HTTP::Put.new(uri)
      req["content-type"] = "#{type}"
      req.body = data if data
      JSON.parse(request(req), symbolize_names: true)
    end

    def delete(*args)
      database = args.shift
      document = args.shift
      revision = args.shift
      
      uri  = "#{@uri}/#{database}"
      uri += "/#{document}"      if document
      uri += "/?rev=#{revision}" if revision

      uri = URI.parse(URI.encode(uri))
      JSON.parse(request(Net::HTTP::Delete.new(uri)), symbolize_names: true)
    end

    def delete_attachment(*args)
      database   = args.shift
      document   = args.shift
      revision   = args.shift
      attachment = args.shift
      
      uri  = "#{@uri}/#{database}/#{document}/#{attachment}?rev=#{revision}"
      uri = URI.parse(URI.encode(uri))
      JSON.parse(request(Net::HTTP::Delete.new(uri)), symbolize_names: true)
    end

    private
    def request(uri)
      response = nil

      begin
        Net::HTTP.start(@connection[:hostname], @connection[:port], :use_ssl => @connection[:ssl]) do |http|
          uri.basic_auth @connection[:username], @connection[:password]

          response = http.request(uri)

          unless response.kind_of?(Net::HTTPSuccess)
            handle_error(uri, response)
            break
          end
        end
      rescue
        return "{\"error\":\"Connection Failed\",\"reason\":\"#{uri.uri} is unreachable.\"}\n"
      end

      response.body
    end

    def handle_error(req, res)
      puts RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
    end
  end
end

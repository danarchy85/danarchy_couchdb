require_relative 'danarchy_couchdb/version'
require 'json'
require 'net/http'

module DanarchyCouchDB
  class Connection
    def initialize(connection)
      @connection = connection
      uri = 'http' if !@connection[:use_ssl]
      uri = 'https' if @connection[:use_ssl]
      @uri = "#{uri}://#{connection[:host]}:#{connection[:port]}"
    end

    def get(*args)
      database = args.shift
      document = args.shift
      revision = args.shift
      
      uri  = "#{@uri}/#{database}"
      uri += "/#{document}"        if document
      uri += "/?rev=#{revision}"   if revision

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
      request(req)
    end

    def delete(*args)
      database = args.shift
      document = args.shift
      revision = args.shift
      
      uri  = "#{@uri}/#{database}"
      uri += "/#{document}"        if document
      uri += "/?rev=#{revision}"   if revision

      uri = URI.parse(URI.encode(uri))
      request(Net::HTTP::Delete.new(uri))
    end

    private
    def request(uri)
      response = nil

      Net::HTTP.start(@connection[:host], @connection[:port], :use_ssl => @connection[:use_ssl]) do |http|
        uri.basic_auth @connection[:user], @connection[:pass]

        response = http.request(uri)

        unless response.kind_of?(Net::HTTPSuccess)
          handle_error(uri, response)
          break
        end
      end

      JSON.parse(response.body, symbolize_names: true)
    end

    def handle_error(req, res)
      puts RuntimeError.new("#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}")
    end
  end
end

# NIS API documentation:
# http://bob.nem.ninja/docs/
# NCC API documentation:
# https://github.com/NewEconomyMovement/NemCommunityClient/blob/master/docs/api.md

require 'net/http'
require 'json'

class NEM

  # NEM object contructor
  # @param cfg [Hash] (optional) containing NIS and/or NCC options   
  def initialize(cfg = nil)
    # default configuration options 
    @config = {
      'nis' => {
        'address' => '127.0.0.1', #NIS remote address
        'port'    => 7890,        #NIS remote port
        'context' => '/'          #NIS web context
      },
      'ncc' => {
        'address' => '127.0.0.1', #NCC remote address
        'port'    => 8989,        #NCC remote port
        'context' => '/ncc/api/'  #NCC web context
      }
    }

    self.set_options(cfg) # set the available configuration options
  end

  # Set the NEM NIS or NCC connection options
  # @param cfg [Hash]
  def set_options(cfg)
    return if cfg.nil? # exit if no configuration found

    cfg.each do |key,val|
      service, option = key.split('_',2)
      @config[service][option] = val
    end
  end

  # @return [Hash] a JSON document
  def ncc_get(uri,data = nil)
    url = _get_valid_call('ncc',uri)
    _send('GET',url,data)
  end
	
  # @return [Hash] a JSON document
  def ncc_post(uri,data = nil)
    url = _get_valid_call('ncc',uri)
    _send('POST',url,data)
  end

  # @return [Hash] a JSON document
  def nis_get(uri,data = nil)
    url = _get_valid_call('nis',uri)
    _send('GET',url,data)
  end
	
  # @return [Hash] a JSON document
  def nis_post(uri,data = nil)
    url = _get_valid_call('nis',uri)
    _send('POST',url,data)
  end

  attr_reader :config

  private

  # Send the json request to NIS or NCC and returns the response output
  # @param method [String] either "POST" or "GET"
  # @param url    [String] valid url link
  # @param data   [String] (optional) in json format or ruby hash containing key -> value pairs
  # @return [Hash] a JSON document
  def _send(method,url,data = {})
    begin
      data = JSON.parse(data) if data.is_a?(String)
    rescue
      raise InvalidArgumentException.new('The data can not be converted into a valid JSON format!')
    end

    uri = URI(url)
    res = if method == 'GET'
            if data != "null"
              uri.query = URI.encode_www_form(data)
            end
            Net::HTTP.get_response(uri)
          elsif method == 'POST'
            https = Net::HTTP.new(uri.host, uri.port)
            req = Net::HTTP::Post.new(uri.request_uri)
            req.content_type = 'application/json'
            req.body = data.to_json
            https.request(req)
          else
            raise NotImplemented.new()
          end
    JSON.parse(res.body)
  end

  # @param type [String] either 'nis' or 'ncc'
  # @return [String] a valid url
  def _get_valid_call(type,uri)
    return nil if type.nil?
    return nil if uri.empty?

    service = @config[type]

    addr = service['address']
    port = service['port']
    cntx = service['context']

    "http://#{addr}:#{port}" + cntx + uri
  end

end

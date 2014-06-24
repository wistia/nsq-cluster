require 'net/http'
require 'uri'

module HTTPWrapper


  def post(path, params = {})
    uri = uri("#{path}?#{URI.encode_www_form(params)}")
    Net::HTTP.post_form(uri, {})
  end


  def get(path, params = {})
    uri = uri(path)
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri)
  end


  private


  def uri(path)
    URI("http://#{@host}:#{@http_port}/#{path}")
  end

end

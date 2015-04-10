require 'net/http'
require 'uri'

module HTTPWrapper


  def post(path, params = {}, body = nil)
    uri          = build_uri("#{path}?#{URI.encode_www_form(params)}")
    request      = Net::HTTP::Post.new(uri)
    request.body = body

    Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end
  end

  def get(path, params = {})
    uri       = uri(path)
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri)
  end

  private


  def build_uri(path)
    URI("http://#{@host}:#{@http_port}/#{path}")
  end

end

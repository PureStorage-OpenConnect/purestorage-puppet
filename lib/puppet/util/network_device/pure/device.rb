require 'puppet/util/network_device'
require_relative 'facts'
require 'puppet/purestorage_api'
require 'uri'

class Puppet::Util::NetworkDevice::Pure::Device

  attr_accessor :api_version, :url, :transport

  def initialize(url, options = {})
    @url = URI.parse(url)
    Puppet.debug("URL = #{@url.inspect}")
    redacted_url = @url.dup
    redacted_url.password = "****" if redacted_url.password

    # Get the API version from config, default to PureStorageApi::REST_VERSION
    @api_version = parse_api_version(@url.query) || PureStorageApi::REST_VERSION

    Puppet.debug("Puppet::Device::Pure: connecting to Pure array: #{redacted_url} using API version #{@api_version}")

    raise ArgumentError, "invalid scheme #{@url.scheme}. Must be https" unless @url.scheme == 'https'
    raise ArgumentError, "no user specified" unless @url.user
    raise ArgumentError, "no password specified" unless @url.password

    @transport = PureStorageApi.new(@url.host, @url.user, @url.password, @api_version)
    Puppet.debug("Transport = #{@transport.inspect}")
    @transport
  end

  def parse_api_version(query)
    Puppet.debug("Got to parse_api_version. Query = #{query.inspect}")
    if query
      params = CGI.parse(query)
      Puppet.debug("Params = #{params.inspect}")
      params['api_version'].first unless params['api_version'].empty?
    end
  end

  def facts
    Puppet.debug("Inside Device FACTS Initialize URL :" + @url)
    @facts ||= Puppet::Util::NetworkDevice::Pure::Facts.new(@transport)
    Puppet.debug("After creating FACTS Object !!!")
    facts = @facts.retrieve
    facts
  end

end

module StalkClimber
  class ConnectionPool < Beaneater::Pool

    class InvalidURIScheme < RuntimeError; end

    # Addresses the pool is connected to
    attr_reader :addresses

    # Test tube used when probing Beanstalk server for information
    attr_reader :test_tube

    # Constructs a Beaneater::Pool from a less strict URL
    # +url+ can be a string i.e 'localhost:11300' or an array of addresses.
    def initialize(addresses = nil, test_tube = nil)
      @addresses = Array(parse_addresses(addresses) || host_from_env || Beaneater.configuration.beanstalkd_url)
      @test_tube = test_tube
      @connections = @addresses.map { |address| Connection.new(address, test_tube) }
    end


    def tubes
      @tubes ||= StalkClimber::Tubes.new(self)
    end


    protected

    # :call-seq:
    #   parse_addresses(addresses) => String
    #
    # Parses the given urls into a collection of beanstalk addresses
    def parse_addresses(addresses)
      return if addresses.empty?
      uris = addresses.is_a?(Array) ? addresses.dup : addresses.split(/[\s,]+/)
      uris.map! do |uri_string|
        uri = URI.parse(uri_string)
        raise(InvalidURIScheme, "Invalid beanstalk URI: #{uri_string}") unless uri.scheme == 'beanstalk'
        "#{uri.host}:#{uri.port || 11300}"
      end
    end

  end
end

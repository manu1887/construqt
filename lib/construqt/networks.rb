module Construqt
  module Networks

    class Network
      attr_reader :address, :phone, :ntp_servers, :routing_tables
      def initialize(name)
        @name = name
        @networks = []
        @domain = "construqt.org"
        @contact = "soa@construqt.org"
        @addresses = Construqt::Addresses.new(self)
        @dns_resolver = nil
        @ntp_servers = Construqt::Addresses::Address.new(self)
        @routing_tables = Construqt::RoutingTables.new(self)
      end

      def add_ntp_server(address)
        if address.kind_of?(Construqt::Addresses::Address)
          @ntp_servers.add_addr(address)
        else
          address.each { |ip| @ntp_servers.add_ip(ip.to_string) }
        end
      end

      def set_address(post_address)
        @address = post_address
      end

      def set_phone(phone)
        @phone = phone
      end

      def addresses
        @addresses
      end

      def add_blocks(*nets)
        nets.each do |net|
          @networks << IPAddress.parse(net)
        end
      end

      def networks
        @networks
      end

      def to_network(ip)
        @networks.find{ |my| (ip.ipv6? == my.ipv6? && ip.ipv4? == my.ipv4?) && my.include?(ip) }
      end

      def set_dns_resolver(nameservers, search)
        @dns_resolver = OpenStruct.new :nameservers => nameservers, :search => search
      end

      def dns_resolver
        @dns_resolver
      end

      def set_domain(domain)
        @domain = domain
      end

      def domain
        @domain
      end

      def set_contact(contact)
        @contact = contact
      end

      def contact
        @contact
      end

      #    def domain(name)
      #      _fqdn = self.fqdn(name)
      #      _fqdn[_fqdn.index('.')+1..-1]
      #    end

      def fqdn(name)
        throw "name must set" unless name
        _name = name.gsub(/[\s_\.]+/, '-')
        return "#{_name}.#{self.domain}" unless _name.include?('.')
        return _name
      end
    end

    @networks = {}
    def self.add(name)
      throw "network with name #{name} exists" if @networks[name]
      @networks[name] = Network.new(name)
    end

    def self.del(name)
      @networks.delete(name)
    end
  end
end

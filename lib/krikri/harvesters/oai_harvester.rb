module Krikri::Harvesters
  ##
  # A harvester implementation for OAI-PMH
  class OAIHarvester
    include Krikri::Harvester
    attr_accessor :client, :name

    ##
    # @param opts [Hash] options to pass through to client requests.
    #   Allowable options are specified in OAI::Const::Verbs. Currently :from,
    #   :until, :set, and :metadata_prefix.
    # @see OAI::Client
    # @see #expected_opts
    def initialize(opts = {})
      uri = opts.delete(:uri)
      @name = opts.fetch(:name, nil)
      @opts = opts.fetch(:oai, {})
      @client = OAI::Client.new(uri)
    end

    ##
    # Sends ListIdentifier requests lazily.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 record ids:
    #
    #     record_ids.take(1000)
    #
    def record_ids(opts = {})
      opts = opts.merge(@opts)
      client.list_identifiers(opts).full.lazy.flat_map(&:identifier)
    end

    # Count on record_ids will request all ids and load them into memory
    # TODO: an efficient implementation of count for OAI
    def count
      raise NotImplementedError
    end

    ##
    # Sends ListRecords requests lazily.
    #
    # The following will only send requests to the endpoint until it
    # has 1000 records:
    #
    #     records.take(1000)
    #
    def records(opts = {})
      opts = opts.merge(@opts)
      client.list_records(opts).full.lazy.flat_map do |rec|
        Krikri::OriginalRecord
          .build(Krikri::Md5Minter.create(rec.header.identifier, name),
                 build_record(rec))

      end
    end

    # TODO: normalize records; there will be differences in XML
    # for different requests
    def get_record(identifier, opts = {})
      opts[:identifier] = identifier
      opts = opts.merge(@opts)
      Krikri::OriginalRecord
        .build(Krikri::Md5Minter.create(identifier, name),
               build_record(client.get_record(opts).record))
    end

    ##
    # @see Krikri::Harvester::expected_opts
    def self.expected_opts
      {
        key: :oai,
        opts: {
          set: {type: :string, required: false, multiple_ok: true},
          metadata_prefix: {type: :string, required: true}
        }
      }
    end

    private

    def build_record(rec)
      doc = Nokogiri::XML::Builder.new do |xml|
        xml.record('xmlns' => 'http://www.openarchives.org/OAI/2.0/') {
          xml.header {
            xml.identifier rec.header.identifier
            xml.datestamp  rec.header.datestamp
            rec.header.set_spec.each do |set|
              xml.set_spec set.text
            end
          }
          xml << rec.metadata.to_s
          xml << rec.about.to_s unless rec.about.nil?
        }
      end
      doc.to_xml
    end
  end
end

module Krikri
  module FieldEnrichment
    include Enrichment

    ##
    # The main enrichment method; runs the enrichment against a record
    #
    # @param record [ActiveTriples::Resource] the record to enrich
    # @param fields [Array] the fields on which to apply the enrichment
    # @return [ActiveTriples::Resource] the enriched record
    def enrich(record, *fields)
      record = record.clone
      return enrich_all(record) if (fields.empty? || fields == [:all])
      fields.each { |f| enrich_field(record, field_to_chain(f)) }
      record
    end

    def enrich_field(record, field_chain)
      field = field_chain.first
      values = record.send(field)
      if field_chain.length == 1
        new_values = values.map { |v| enrich_value(v) }.flatten.compact
        record.send("#{field}=".to_sym, new_values)
      else
        resources(values).each { |v| enrich_field(v, field_chain[1..-1]) }
      end
      record
    end

    def enrich_all(record)
      list_fields(record).each do |field|
        enrich_field(record, field_to_chain(field))
      end
      record
    end
  end
end

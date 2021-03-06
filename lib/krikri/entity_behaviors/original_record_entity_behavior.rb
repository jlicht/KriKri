
module Krikri
  ##
  # A behavior that provides methods for working with original records
  # (as defined by Krikri::OriginalRecord), in the context of entities that
  # are generated by activities.
  #
  # @see Krikri::EntityBehavior
  #
  class OriginalRecordEntityBehavior < Krikri::EntityBehavior

    ##
    # @param load [Boolean]  Whether to load the whole record from the LDP
    #   server.  OriginalRecord.load is slow, because it results in a network
    #   request, so this provides the possibility of avoiding it.
    #   Default: true.
    #
    # @param include_invalidated [Boolean] Whether to include entities that
    #   have been invalidated with prov:invalidatedAtTime.  Default: false
    #
    # @see Krikri::EntityBehavior::entities
    #
    # @return [Enumerator] OriginalRecord objects
    #
    def entities(load = true, include_invalidated = false)
      activity_uris(include_invalidated) do |uri|
        load ? OriginalRecord.load(uri) : OriginalRecord.new(uri)
      end
    end
  end
end

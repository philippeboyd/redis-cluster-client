# frozen_string_literal: true

class RedisClient
  class Cluster
    module ErrorIdentification
      def self.client_owns_error?(err, client)
        err.is_a?(TaggedError) && err.from?(client)
      end

      module TaggedError
        attr_accessor :config_instance

        def from?(client)
          client.config.equal?(config_instance)
        end
      end

      module Middleware
        def connect(config)
          super
        rescue RedisClient::Error => e
          identify_error(e, config)
          raise
        end

        def call(_command, config)
          super
        rescue RedisClient::Error => e
          identify_error(e, config)
          raise
        end
        alias call_pipelined call

        private

        def identify_error(err, config)
          err.singleton_class.include(TaggedError)
          err.config_instance = config
        end
      end
    end
  end
end
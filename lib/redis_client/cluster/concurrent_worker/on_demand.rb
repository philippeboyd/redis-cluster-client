# frozen_string_literal: true

class RedisClient
  class Cluster
    module ConcurrentWorker
      class OnDemand
        def initialize
          @q = SizedQueue.new(::RedisClient::Cluster::ConcurrentWorker.size)
        end

        def new_group(size:)
          ::RedisClient::Cluster::ConcurrentWorker::Group.new(worker: self, size: size)
        end

        def push(task)
          @q << spawn_worker(task, @q)
        end

        def close
          @q.clear
          @q.close
          nil
        end

        private

        def spawn_worker(task, queue)
          Thread.new(task, queue) do |t, q|
            t.exec
            q.pop
          end
        end
      end
    end
  end
end

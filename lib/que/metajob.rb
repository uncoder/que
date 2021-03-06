# frozen_string_literal: true

# A thin wrapper around a job's data that lets us do things like sort easily and
# make sure that run_at is in the format we want.

module Que
  class Metajob
    SORT_KEYS = [:priority, :run_at, :id].freeze

    attr_reader :job

    def initialize(job)
      set_job(job)
    end

    def set_job(job)
      if (run_at = job.fetch(:run_at)).is_a?(Time)
        job[:run_at] = run_at.utc.iso8601(6)
      end

      @job = job
    end

    def id
      job.fetch(:id)
    end

    def <=>(other)
      k1 = job
      k2 = other.job

      SORT_KEYS.each do |key|
        value1 = k1.fetch(key)
        value2 = k2.fetch(key)

        return -1 if value1 < value2
        return  1 if value1 > value2
      end

      0
    end

    def priority_sufficient?(threshold)
      threshold.nil? || job.fetch(:priority) <= threshold
    end
  end
end

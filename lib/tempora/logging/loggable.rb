module Tempora
  module Loggable
    def loggable?
      false
    end

    def acts_as_loggable
      class_eval do
        # has_many ...
        has_many :logs, as: :loggable

        def self.loggable?
          true
        end

      end
    end
  end
end

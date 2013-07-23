module Tempora
  module Logging
    module Logger
      extend ActiveSupport::Concern

      module ClassMethods
        def is_logger?
          false
        end

        def acts_as_logger(opts={})
          has_many :logs, as: :logger, class_name: "Tempora::Logging::Log"
          include LoggerMethods
          extend LoggerClassMethods
        end
      end

      module LoggerClassMethods
        def is_logger?
          true
        end

        def loggable_assoc
          assoc = []
          self.reflections.values.each do |ref|
            if ref.klass.is_loggable?
              assoc.push ref
            end
          end
          assoc
        end
      end

      module LoggerMethods
        def log(loggable, opts={})
          return false unless loggable.respond_to?(:is_loggable?) && loggable.is_loggable?
          logs.create loggable: loggable, event: "#{loggable.class.to_s}::#{opts[:event]}"
        end

        def ratings
          Tempora.redis.hgetall Tempora::KeyMapper.logger_key self
        end

        def is_logger?
          true
        end

        def is_loggable?
          false
        end

        def assoc_with? loggable
          if loggable.is_loggable?
            assoc = loggable.send(loggable.class.logger_assoc.select{
              |a| a.klass == self.class
            }.first.plural_name).find self rescue nil
          end
          assoc.present?
        end
      end
    end
  end
end
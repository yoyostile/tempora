module Tempora
  module Logging
    module Base
      def is_tempora_assoc?(obj)
        obj.send(obj.class.tempora_assoc.detect{
          |a| a.klass == self.class
          }.plural_name).exists? self rescue nil
      end
    end
  end
end
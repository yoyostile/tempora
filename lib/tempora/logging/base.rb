module Tempora
  module Logging
    module Base
      def is_tempora_assoc?(obj)
        obj.send(obj.class.tempora_assoc.select{
          |a| a.klass == self.class
          }.first.plural_name).exists? self rescue nil
      end
    end
  end
end
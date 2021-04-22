module Xip
  module Services
    module Messagebird
      class MessagebirdServiceMessage < Xip::ServiceMessage
        attr_accessor :conversation_id,
                      :messagebird_id,
                      :platform,
                      :display_name,
                      :first_name,
                      :last_name

      end
    end
  end
end

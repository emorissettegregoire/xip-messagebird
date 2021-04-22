# frozen_string_literal: true
require 'xip/services/messagebird/client'

module Xip
  module Services
    module Messagebird

      class Setup

        class << self
          def trigger
            Xip::Logger.l(topic: "messagebird", message: "There is no setup needed!")
          end
        end

      end

    end
  end
end

# frozen_string_literal: true
require 'messagebird'
require 'xip/services/messagebird/message_handler'
require 'xip/services/messagebird/messagebird_service_message'
require 'xip/services/messagebird/reply_handler'
require 'xip/services/messagebird/setup'

module Xip
  module Services
    module Messagebird
      class Client < Xip::Services::BaseClient
        attr_reader :messagebird_client, :reply

        def initialize(reply:)
          @reply = reply
          access_key = Xip.config.messagebird.access_key
          @messagebird_client = MessageBird::Client.new(access_key)
        end

        def transmit
          # Don't transmit anything for delays
          return true if reply.blank?

          response = messagebird_client.send_conversation_message(reply[:from], reply[:to], reply)

          if response.status == "failed" || response.status == "rejected"
            case response.error.code
            when 301 # Message failed to send
              raise Xip::Errors::UserOptOut
            when 302 # Contact is not registered on WhatsApp
              raise Xip::Errors::UserOptOut
            when 470 # Outside the support window for freeform messages
              raise Xip::Errors::UserOptOut
            when 2 # Request not allowed
              raise Xip::Errors::UserOptOut
            when 25 # Not enough balance
              raise Xip::Errors::UserOptOut
            else
              raise
            end
          end

          message = "Transmitting. Response: #{response.status}: "
          if response.status == "failed" || response.status == "rejected"
            message += response.error.description
          end
          Xip::Logger.l(topic: "messagebird", message: message)
        end
      end
    end
  end
end

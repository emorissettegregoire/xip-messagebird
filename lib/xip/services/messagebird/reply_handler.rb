# frozen_string_literal: true
module Xip
  module Services
    module Messagebird
      class ReplyHandler < Xip::Services::BaseReplyHandler

        attr_reader :recipient_id, :reply

        def initialize(recipient_id: nil, reply: nil)
          @recipient_id = recipient_id
          @reply = reply
        end

        def text
          check_text_length

          translated_reply = reply['text']

          suggestions = generate_suggestions(suggestions: reply['suggestions'])
          buttons = generate_buttons(buttons: reply['buttons'])

          if suggestions.present?
            translated_reply = [
              translated_reply,
              I18n.t(
                "xip.messagebird.respond_with_a_number",
                default: "Respond with a number:"
              )
            ].join("\n\n")

            suggestions.each_with_index do |suggestion, i|
              translated_reply = [
                translated_reply,
                I18n.t(
                  "xip.messagebird.number_option",
                  number: i + 1,
                  suggestion: suggestion,
                  default: "%{number} for %{suggestion}"
                )
              ].join("\n")
            end
          end

          if buttons.present?
            buttons.each do |button|
              translated_reply = [
                translated_reply,
                button
              ].join("\n\n")
            end
          end

          # format_response({ body: translated_reply })
          format_response(type: 'text', content: { text: translated_reply })
        end

        def image
          check_text_length

          format_response(type: 'image', content: { image: { caption: reply['text'], url: reply['image_url'] } })
        end

        def audio
          check_text_length

          format_response(type: 'audio', content: { audio: { caption: reply['text'], url: reply['audio_url'] } })
        end

        def video
          check_text_length

          format_response(type: 'video', content: { video: { caption: reply['text'], url: reply['video_url'] } })
        end

        def file
          check_text_length

          format_response(type: 'file', content: { file: { caption: reply['text'], url: reply['file_url'] } })
        end

        def location
          check_text_length

          format_response(type: 'location', content: { location: { latitude: reply['latitude'], longitude: reply['longitude'] } })
        end

        def delay

        end

        private

        def check_text_length
          if reply['text'].present? && reply['text'].size > 1600
            raise(ArgumentError, "Text messages must be 1600 characters or less.")
          end
        end

        def format_response(response)
          sender_info = {
            from: Xip.config.messagebird.channel_id.to_s,
            to: recipient_id.to_s
          }
          response.merge(sender_info)
        end

        def generate_suggestions(suggestions:)
          return if suggestions.blank?

          mf = suggestions.collect do |suggestion|
            suggestion['text']
          end.compact
        end

        def generate_buttons(buttons:)
          return if buttons.blank?

          sms_buttons = buttons.map do |button|
            case button['type']
            when 'url'
              "#{button['text']}: #{button['url']}"
            when 'payload'
              I18n.t(
                "xip.messagebird.text_option",
                text: button['text'],
                option: button['payload'],
                default: "For %{text}: Text %{option}"
              )
            when 'call'
              "#{button['text']}: #{button['phone_number']}"
            end
          end.compact

          sms_buttons
        end
      end
    end
  end
end

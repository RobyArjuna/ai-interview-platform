# frozen_string_literal: true

# PdpSanitizer provides redaction utilities for Personal Identifiable Information (PII)
# to comply with Indonesia's Personal Data Protection Law (UU PDP).
module PdpSanitizer
  # Regex pattern for 16-digit NIK (Nomor Induk Kependudukan)
  NIK_PATTERN = /\b\d{16}\b/.freeze

  # Regex pattern for Indonesian Phone Numbers (+62 or 08xx-xxxx-xxxx)
  PHONE_PATTERN = /(?:\+62|62|0)8[1-9][0-9]{7,11}\b/.freeze

  # Regex pattern for Email Addresses
  EMAIL_PATTERN = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/.freeze

  class << self
    # Redacts all detected PII from the provided text string.
    def sanitize(text)
      return text if text.nil? || text.empty?

      sanitized = text.dup
      sanitized.gsub!(NIK_PATTERN, '[REDACTED NIK]')
      sanitized.gsub!(EMAIL_PATTERN, '[REDACTED EMAIL]')
      sanitized.gsub!(PHONE_PATTERN, '[REDACTED PHONE]')
      sanitized
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'pdp_sanitizer'

RSpec.describe PdpSanitizer do
  describe '.sanitize' do
    it 'returns nil or empty text unchanged' do
      expect(described_class.sanitize(nil)).to be_nil
      expect(described_class.sanitize('')).to eq('')
    end

    it 'redacts 16-digit NIK numbers' do
      raw_text = 'Kandidat NIK 3171012345678901 telah lolos verifikasi.'
      sanitized = described_class.sanitize(raw_text)
      expect(sanitized).to eq('Kandidat NIK [REDACTED NIK] telah lolos verifikasi.')
    end

    it 'redacts Indonesian phone numbers' do
      raw_text = 'Hubungi kandidat di 081234567890 atau +6281987654321.'
      sanitized = described_class.sanitize(raw_text)
      expect(sanitized).to eq('Hubungi kandidat di [REDACTED PHONE] atau [REDACTED PHONE].')
    end

    it 'redacts email addresses' do
      raw_text = 'Email kandidat: john.doe@example.com'
      sanitized = described_class.sanitize(raw_text)
      expect(sanitized).to eq('Email kandidat: [REDACTED EMAIL]')
    end

    it 'redacts combined PII in candidate transcript turns' do
      raw_text = 'Saya Budi, NIK 3201123456789012, phone 085712345678, email budi@test.id'
      sanitized = described_class.sanitize(raw_text)
      expect(sanitized).to eq('Saya Budi, NIK [REDACTED NIK], phone [REDACTED PHONE], email [REDACTED EMAIL]')
    end
  end
end

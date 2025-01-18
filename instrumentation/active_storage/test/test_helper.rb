# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

ENV['RAILS_ENV'] = 'test'

require 'logger'
require 'bundler/setup'
Bundler.require(:default, :development, :test)

require 'active_storage'
require 'minitest/autorun'
require 'test_helpers/app_config'

# global opentelemetry-sdk setup:
EXPORTER = OpenTelemetry::SDK::Trace::Export::InMemorySpanExporter.new
span_processor = OpenTelemetry::SDK::Trace::Export::SimpleSpanProcessor.new(EXPORTER)

OpenTelemetry::SDK.configure do |c|
  c.error_handler = ->(exception:, message:) { raise(exception || message) }
  c.logger = Logger.new($stderr, level: ENV.fetch('OTEL_LOG_LEVEL', 'fatal').to_sym)
  c.use 'OpenTelemetry::Instrumentation::ActiveStorage'
  c.add_span_processor span_processor
end
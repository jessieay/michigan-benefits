# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.uncountable %w[
    expenses_additional_sources
    household_health_situations
    household_personal_details
    household_situations
    income_additional_sources
    income_other_assets
    maybe_submit_documents
    preferences_reminders
  ]
end

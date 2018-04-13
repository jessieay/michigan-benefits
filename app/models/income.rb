class Income < ApplicationRecord
  belongs_to :household_member

  INCOME_LABELS_AND_KEYS = {
    unemployment: "Unemployment",
    pension: "Pension",
    retirement: "Retirement",
    social_security: "Social Security",
    ssi: "Supplemental Security Income (SSI) or Disability",
    alimony: "Alimony",
    child_support: "Child Support",
    workers_comp: "Worker's Compensation",
  }.freeze

  def income_label
    INCOME_LABELS_AND_KEYS[income_type.to_sym]
  end
end

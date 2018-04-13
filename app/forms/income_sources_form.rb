class IncomeSourcesForm < Form
  set_member_attributes(
    :id,
    :unemployment_income,
    :pension_income,
    :retirement_income,
    :social_security_income,
    :ssi_income,
    :alimony_income,
    :child_support_income,
    :workers_comp_income,
  )

  set_application_attributes(:incomes)
end

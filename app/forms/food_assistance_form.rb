class FoodAssistanceForm < Form
  include MultiparameterAttributeAssignment

  set_application_attributes(:members)
  set_member_attributes(:requesting_food)
end

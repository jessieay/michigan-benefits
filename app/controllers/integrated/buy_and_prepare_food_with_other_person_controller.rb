module Integrated
  class BuyAndPrepareFoodWithOtherPersonController < FormsController
    def self.skip?(application)
      if application.unstable_housing? || application.members.count != 2
        true
      else
        false
      end
    end

    def update
      current_application.members.second.update(member_params)
      redirect_to(next_path)
    end

    def form_class
      NullStep
    end

    private

    def form_attrs
      %i[buy_and_prepare_food_with_other_person]
    end

    def member_params
      requesting_food = form_params.fetch(:buy_and_prepare_food_with_other_person) == "true" ? "yes" : "no"
      { requesting_food: requesting_food }
    end
  end
end

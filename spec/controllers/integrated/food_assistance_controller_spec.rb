require "rails_helper"

RSpec.describe Integrated::FoodAssistanceController do
  describe "#update" do
    context "with valid params" do
      it "marks members as requesting food" do
        current_app = create(:common_application,
                             members: [create(:household_member), create(:household_member)])
        session[:current_application_id] = current_app.id

        member1 = current_app.members[0]
        member2 = current_app.members[1]

        valid_params = {
          form: {
            members: {
              member1.id => { "requesting_food" => "yes" },
              member2.id => { "requesting_food" => "yes" },
            },
          },
        }

        put :update, params: valid_params

        current_app.reload

        expect(current_app.primary_member.requesting_food_yes?).to be_truthy
        expect(current_app.members[1].requesting_food_yes?).to be_truthy
      end
    end
  end
end

require "rails_helper"

RSpec.describe Integrated::BuyAndPrepareFoodWithOtherPersonController do
  describe "#skip?" do
    context "when applicant has stable housing" do
      context "when household has two members" do
        it "returns false" do
          application = create(:common_application,
            living_situation: "stable_address",
            members: build_list(:household_member, 2))

          skip_step = Integrated::BuyAndPrepareFoodWithOtherPersonController.skip?(application)
          expect(skip_step).to eq(false)
        end
      end

      context "when household has one or more than two members" do
        it "returns true" do
          single_member_application = create(:common_application,
            living_situation: "stable_address",
            members: build_list(:household_member, 1))

          three_member_application = create(:common_application,
            living_situation: "stable_address",
            members: build_list(:household_member, 3))

          single_member_skip_step = Integrated::BuyAndPrepareFoodWithOtherPersonController.skip?(single_member_application)
          expect(single_member_skip_step).to eq(true)

          three_member_skip_step = Integrated::BuyAndPrepareFoodWithOtherPersonController.skip?(three_member_application)
          expect(three_member_skip_step).to eq(true)
        end
      end
    end

    context "when applicant has unstable housing" do
      it "returns true" do
        application = create(:common_application, living_situation: "temporary_address")

        skip_step = Integrated::BuyAndPrepareFoodWithOtherPersonController.skip?(application)
        expect(skip_step).to eq(true)
      end
    end
  end

  describe "#update" do
    context "when client indicates they buy and prepare food with person" do
      it "indicates second member is applying for food assistance" do
        members = build_list(:household_member, 2)
        current_app = create(:common_application, members: members)

        session[:current_application_id] = current_app.id

        put :update, params: { form: { buy_and_prepare_food_with_other_person: "true" } }

        members.map(&:reload)

        expect(members.second.requesting_food).to eq("yes")
      end

      context "when client indicates they don't buy and prepare food other with person" do
        it "indicates second member is not applying for food assistance" do
          members = build_list(:household_member, 2)
          current_app = create(:common_application, members: members)

          session[:current_application_id] = current_app.id

          put :update, params: { form: { buy_and_prepare_food_with_other_person: "false" } }

          members.map(&:reload)

          expect(members.second.requesting_food).to eq("no")
        end
      end
    end
  end
end

require "rails_helper"

RSpec.describe Integrated::IncomeSourcesController do
  describe "edit" do
    it "assigns existing income sources" do
      primary_member = build(:household_member, incomes: [
        build(:income, income_type: "unemployment"),
      ])

      current_app = create(
        :common_application,
        members: [primary_member],
      )

      session[:current_application_id] = current_app.id

      get :edit

      expect(assigns[:form].pension_income).to be_falsey
      expect(assigns[:form].unemployment_income).to be_truthy
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:valid_params) do
        {
          unemployment_income: "1",
          pension_income: "1",
          ssi_income: "0",
        }

        {
          incomes: [
            "unemployment",
            "",
            "pension"
          ]
        }
      end

      it "creates incomes from params" do
        current_app = create(
          :common_application,
          :single_member,
        )

        session[:current_application_id] = current_app.id

        put :update, params: { form: valid_params }

        current_app.reload

        income_types = current_app.primary_member.incomes.map(&:income_type)

        expect(income_types).to match_array(["unemployment", "pension"])
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        {
          baby_count: "0",
        }
      end

      it "renders edit without updating" do
        pregnant_member = build(:household_member, pregnant: "yes")

        current_app = create(
          :common_application,
          navigator: build(:application_navigator, anyone_pregnant: true),
          members: [pregnant_member],
        )

        session[:current_application_id] = current_app.id

        put :update, params: { form: invalid_params }

        expect(response).to render_template(:edit)
      end
    end
  end
end

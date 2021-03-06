require "rails_helper"

RSpec.describe CommonApplication do
  describe "scopes" do
    describe ".food_household_members" do
      it "returns members applying for food assistance who buy and prepare food together" do
        in_household = build(:household_member, requesting_food: "yes", buy_and_prepare_food_together: "yes")

        application = create(:common_application,
          members: [
            in_household,
            build(:household_member, requesting_food: "yes", buy_and_prepare_food_together: "no"),
            build(:household_member, requesting_food: "yes", buy_and_prepare_food_together: "unfilled"),
            build(:household_member, requesting_food: "no", buy_and_prepare_food_together: "yes"),
            build(:household_member, requesting_food: "unfilled", buy_and_prepare_food_together: "yes"),
          ])

        expect(application.food_household_members.count).to eq(1)
        expect(application.food_household_members.first).to eq(in_household)
      end

      it "orders by time created at" do
        second_member = build(:household_member, :in_food_household, created_at: Time.now)
        first_member = build(:household_member, :in_food_household, created_at: Time.now - 1.day)

        application = create(:common_application, members: [
                               second_member,
                               first_member,
                             ])

        expect(application.food_household_members.first).to eq(first_member)
        expect(application.food_household_members.second).to eq(second_member)
      end
    end

    describe ".food_applying_members" do
      it "returns all members requesting food assistance" do
        in_household = build(:household_member, requesting_food: "yes")

        application = create(:common_application,
          members: [
            in_household,
            build(:household_member, requesting_food: "no"),
            build(:household_member),
          ])

        expect(application.food_applying_members.count).to eq(1)
        expect(application.food_applying_members.first).to eq(in_household)
      end
    end

    describe ".healthcare_applying_members" do
      it "returns all members requesting healthcare coverage" do
        in_household = build(:household_member, requesting_healthcare: "yes")

        application = create(:common_application,
          members: [
            in_household,
            build(:household_member, requesting_healthcare: "no"),
            build(:household_member),
          ])

        expect(application.healthcare_applying_members.count).to eq(1)
        expect(application.healthcare_applying_members.first).to eq(in_household)
      end
    end

    describe ".tax_household_members" do
      it "returns all members in the tax household" do
        in_household = [
          build(:household_member, tax_relationship: "primary"),
          build(:household_member, tax_relationship: "married_filing_jointly"),
          build(:household_member, tax_relationship: "dependent"),
        ]

        not_in_household = [
          build(:household_member, tax_relationship: "unfilled"),
          build(:household_member, tax_relationship: "married_filing_separately"),
          build(:household_member, tax_relationship: "not_included"),
        ]

        application = create(:common_application, members: in_household + not_in_household)

        expect(application.tax_household_members.count).to eq(3)
        expect(application.tax_household_members).to match_array(in_household)
      end
    end
  end

  describe "#single_member_household?" do
    context "when one member in household" do
      it "returns true" do
        application = create(:common_application, :single_member)

        expect(application.single_member_household?).to be_truthy
      end
    end

    context "when more than one member in household" do
      it "returns false" do
        application = create(:common_application, :multi_member)

        expect(application.single_member_household?).to be_falsey
      end
    end

    context "when zero members in household" do
      it "returns false" do
        application = create(:common_application)

        expect(application.single_member_household?).to be_falsey
      end
    end
  end

  describe "#unstable_housing?" do
    context "with stable housing" do
      it "returns false" do
        application = build(:common_application, living_situation: "stable_address")
        expect(application.unstable_housing?).to eq(false)
      end
    end

    context "when homeless" do
      it "returns true" do
        application = build(:common_application, living_situation: "homeless")
        expect(application.unstable_housing?).to eq(true)
      end
    end

    context "with temporary housing" do
      it "returns true" do
        application = build(:common_application, living_situation: "temporary_address")
        expect(application.unstable_housing?).to eq(true)
      end
    end

    context "when not answered" do
      it "returns false" do
        application = build(:common_application)
        expect(application.unstable_housing?).to eq(false)
      end
    end
  end

  describe "#applying_for_food_assistance?" do
    it "returns true when at least one household member is applying for food" do
      application = create(:common_application,
                           members: [create(:household_member, requesting_food: "yes")])
      expect(application.applying_for_food_assistance?).to be_truthy
    end

    it "returns false when no one is applying for food" do
      application = create(:common_application,
                           members: [create(:household_member, requesting_food: "no")])
      expect(application.applying_for_food_assistance?).to be_falsey
    end
  end

  describe "#applying_for_healthcare?" do
    it "returns true when at least one household member is applying for healthcare" do
      application = create(:common_application,
        members: [create(:household_member, requesting_healthcare: "yes")])
      expect(application.applying_for_healthcare?).to be_truthy
    end

    it "returns false when no one is applying for healthcare" do
      application = create(:common_application,
        members: [create(:household_member, requesting_healthcare: "no")])
      expect(application.applying_for_healthcare?).to be_falsey
    end
  end

  describe "#anyone_employed?" do
    it "returns true when at least one household member has a positive job count" do
      application = create(:common_application,
                           members: [create(:household_member, job_count: "1")])
      expect(application.anyone_employed?).to be_truthy
    end

    it "returns false when no job count is set" do
      application = create(:common_application,
                           members: [create(:household_member)])
      expect(application.anyone_employed?).to be_falsey
    end

    it "returns false when job count is 0" do
      application = create(:common_application,
                           members: [create(:household_member, job_count: "0")])
      expect(application.anyone_employed?).to be_falsey
    end
  end

  describe "#primary_member" do
    context "when at least one member is present" do
      it "returns the member that was first created" do
        application = create(:common_application, :multi_member)
        expect(application.primary_member).to eq(application.members.first)
      end
    end

    context "when no members are present" do
      it "returns nil" do
        application = create(:common_application)
        expect(application.primary_member).to be_nil
      end
    end
  end

  describe "#non_applicant_members" do
    context "when one member is present" do
      it "returns an empty array" do
        application = create(:common_application, :single_member)
        expect(application.non_applicant_members).to eq([])
      end
    end

    context "when 2 members are present" do
      it "returns an array without the primary member" do
        application = create(:common_application, :multi_member)

        expect(application.non_applicant_members).to match_array([application.members.second,
                                                                  application.members.third])
      end
    end
  end

  describe "#display_name" do
    it "returns the display name of the primary member" do
      application = create(:common_application,
                           members: [build(:household_member, first_name: "Octopus", last_name: "Cuttlefish")])
      expect(application.display_name).to eq("Octopus Cuttlefish")
    end
  end
end

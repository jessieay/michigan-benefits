require "rails_helper"

RSpec.describe Member do
  describe "scopes" do
    describe ".filing_taxes" do
      it "returns members filing taxes as Single or Joint" do
        _no_relationship = create(:member, tax_relationship: nil)
        _dependent = create(:member, tax_relationship: "Dependent")
        filing1 = create(:member, tax_relationship: "Single")
        filing2 = create(:member, tax_relationship: "Joint")

        expect(Member.filing_taxes).to eq [filing1, filing2]
      end
    end

    describe ".dependents" do
      it "returns members that are dependents of primary applicant" do
        _no_relationship = create(:member, tax_relationship: nil)
        dependent = create(:member, tax_relationship: "Dependent")
        _filing1 = create(:member, tax_relationship: "Single")
        _filing2 = create(:member, tax_relationship: "Joint")

        expect(Member.dependents).to eq [dependent]
      end
    end

    describe ".no_tax_relationship" do
      it "returns members NOT filing taxes with primary applicant" do
        no_relationship = create(:member, tax_relationship: nil)
        _dependent = create(:member, tax_relationship: "Dependent")
        _filing1 = create(:member, tax_relationship: "Single")
        _filing2 = create(:member, tax_relationship: "Joint")

        expect(Member.no_tax_relationship).to eq [no_relationship]
      end
    end

    describe ".first_insurance_holder" do
      it "returns the first member that is insured" do
        create(:member, insured: false, requesting_health_insurance: true)
        create(:member, insured: true, requesting_health_insurance: false)
        joel = create(:member, insured: true, requesting_health_insurance: true)

        expect(Member.insured).to eq [joel]
      end
    end

    describe ".after" do
      it "returns the next member _after_ the provided member" do
        joel = create(:member)
        jessie = create(:member)
        christa = create(:member)

        expect(Member.after(joel)).to eq [jessie, christa]
        expect(Member.after(jessie)).to eq [christa]
      end
    end
  end

  describe "#female?" do
    it "is true if the sex is female" do
      expect(build(:member, sex: "female")).to be_female
    end

    it "is false if the sex is male" do
      expect(build(:member, sex: "male")).not_to be_female
    end
  end

  describe "#male?" do
    it "is true if the sex is male" do
      expect(build(:member, sex: "male")).to be_male
    end

    it "is false if the sex is female" do
      expect(build(:member, sex: "female")).not_to be_male
    end
  end

  describe "#monthly_income" do
    context "unemployed" do
      it "returns 0" do
        member = build(:member, employment_status: "not_employed")

        expect(member.monthly_income).to eq 0
      end
    end

    context "self employed" do
      it "returns monthly income" do
        member = build(
          :member,
          employment_status: "self_employed",
          self_employed_monthly_income: 100,
        )

        expect(member.monthly_income).to eq 100
      end
    end

    context "employed" do
      it "calls MonthlyIncomeCalculator to find monthly income" do
        member = build(
          :member,
          employment_status: "employed",
          employed_pay_quantity: 10,
          employed_pay_interval: "Hourly",
          employed_hours_per_week: 10,
        )
        calc_double = double(run: true)
        allow(MonthlyIncomeCalculator).to receive(:new).with(
          pay_interval: "Hourly",
          pay_quantity: 10,
          hours_per_week: 10,
        ).and_return(calc_double)

        member.monthly_income

        expect(calc_double).to have_received(:run)
      end
    end
  end

  describe "#spouse_options" do
    it "returns all other married members in the application" do
      primary_member = build(:member, married: true)
      married_member = build(:member, married: true)
      unmarried_member = build(:member, married: false)

      create(
        :medicaid_application,
        members: [primary_member, married_member, unmarried_member],
      )

      expect(primary_member.spouse_options.size).to eq 2
      expect(primary_member.spouse_options).to include married_member
      expect(primary_member.spouse_options).not_to include unmarried_member
    end
  end

  describe "#mi_bridges_formatted_name" do
    context "name is over 10 chars" do
      it "cuts name off at 10 chars" do
        time = Time.utc(2008, 9, 1, 10, 5, 0)
        Timecop.freeze(time) do
          member = build(
            :member,
            first_name: "JacquelineR",
            birthday: DateTime.parse("June 20, 1990"),
          )

          expect(member.mi_bridges_formatted_name).to eq "Jacqueline (18)"
        end
      end
    end

    context "name is shorter than 10 chars" do
      it "returns full first name and age" do
        time = Time.utc(2008, 9, 1, 10, 5, 0)
        Timecop.freeze(time) do
          member = build(
            :member,
            first_name: "Lala",
            birthday: DateTime.parse("June 20, 1990"),
          )

          expect(member.mi_bridges_formatted_name).to eq "Lala (18)"
        end
      end
    end
  end

  describe "#age" do
    it "returns the age today is before this year's birthday" do
      time = Time.utc(2008, 1, 1, 10, 5, 0)
      Timecop.freeze(time) do
        member = build(
          :member,
          first_name: "Lala",
          birthday: DateTime.parse("June 20, 1990"),
        )

        expect(member.age).to eq 17
      end
    end

    it "returns the age today is after this year's birthday" do
      time = Time.utc(2008, 9, 1, 10, 5, 0)
      Timecop.freeze(time) do
        member = build(
          :member,
          first_name: "Lala",
          birthday: DateTime.parse("June 20, 1990"),
        )

        expect(member.age).to eq 18
      end
    end
  end

  describe "#other_income_types" do
    it "accepts all valid choices" do
      member = Member.new
      member.other_income_types = [
        "alimony",
        "other",
        "pension",
        "retirement",
        "social_security",
        "unemployment",
      ]
      member.valid?
      expect(member.errors).to_not include(:other_income_types)
    end

    it "accepts empty choices" do
      member = Member.new
      member.other_income_types = []
      member.valid?
      expect(member.errors).to_not include(:other_income_types)
    end

    it "rejects invalid choices" do
      member = Member.new
      member.other_income_types = [
        "side_hustle",
      ]
      member.valid?
      expect(member.errors).to include(:other_income_types)
    end
  end
end

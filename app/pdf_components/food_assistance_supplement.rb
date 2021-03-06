class FoodAssistanceSupplement
  include Integrated::PdfAttributes

  def initialize(benefit_application)
    @benefit_application = benefit_application
  end

  def source_pdf_path
    "app/lib/pdfs/FoodAssistanceProgramSupplement.pdf"
  end

  def fill?
    true
  end

  def attributes
    supplement_attributes
  end

  def output_file
    @_output_file ||= Tempfile.new(["food_assistance_supplement", ".pdf"], "tmp/")
  end

  private

  attr_reader :benefit_application

  def supplement_attributes
    {
      anyone_buys_food_separately: yes_no_or_unfilled(
        yes: non_household_members_applying_for_snap.any?,
        no: non_household_members_applying_for_snap.none?,
      ),
      anyone_buys_food_separately_names: member_names(non_household_members_applying_for_snap),
    }
  end

  def non_household_members_applying_for_snap
    @_non_household_members_applying_for_snap =
      benefit_application.food_applying_members - benefit_application.food_household_members
  end
end

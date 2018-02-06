class StepNavigation
  ALL = {
    "Introduction" => [
      IntroduceYourselfController,
      ContactInformationController,
      MailingAddressController,
      ResidentialAddressController,
      IntroductionCompleteController,
    ],
    "Your Household" => [
      HouseholdIntroductionController,
      PersonalDetailController,
      HouseholdMembersOverviewController,
      HouseholdMoreInfoController,
      HouseholdMoreInfoPerMemberController,
    ],
    "Money & Income" => [
      IncomeIntroductionController,
      IncomeChangeController,
      IncomeChangeExplanationController,
      IncomeEmploymentStatusController,
      IncomeDetailsPerMemberController,
      IncomeAdditionalSourcesController,
      IncomeAdditionalController,
      IncomeOtherAssetsController,
      IncomeOtherAssetsContinuedController,
    ],
    "Expenses" => [
      ExpensesIntroductionController,
      ExpensesHousingController,
      ExpensesAdditionalSourcesController,
      ExpensesAdditionalController,
    ],
    "General" => [
      ContactPreferenceController,
      ContactConfirmPhoneNumberController,
      AuthorizedRepresentativeController,
      GeneralAnythingElseController,
    ],
    "Submit Documents" => [
      DocumentGuideController,
      DocumentsController,
    ],
    "Legal" => [
      LegalAgreementController,
      SignAndSubmitController,
    ],
    "Success" => [
      SuccessController,
    ],
  }.freeze

  SUBSTEPS = {
    HouseholdAddMemberController => HouseholdMembersOverviewController,
    HouseholdRemoveMemberController => HouseholdMembersOverviewController,
    IntroductionChangeOfficeLocationController =>
      IntroductionCompleteController,
  }.freeze

  class << self
    delegate :first, to: :steps

    def sections
      ALL
    end

    def steps
      @steps ||= ALL.values.flatten.freeze
    end

    def steps_and_substeps
      @steps_and_substeps ||= (steps + SUBSTEPS.keys).uniq.freeze
    end
  end

  delegate :steps, to: :class

  def initialize(step_instance_or_class)

    @controller = step_instance_or_class
  end

  def next
    steps_until_end = steps[index+1..-1]
    steps_until_end.find do |controller_class|
      !controller_class.skip?(@controller.current_application)
    end
  end

  def previous
    steps_to_beginning = steps[0..index-1].reverse
    steps_to_beginning.find do |controller_class|
      !controller_class.skip?(@controller.current_application)
    end
  end

  def index
    steps.index(@controller.class)
  end

  def parent
    self.class.new(SUBSTEPS[@controller.class])
  end

end

module Integrated
  class WhoIsHealthcareEnrolledController < MultipleMembersController
    def self.skip?(application)
      return true if application.single_member_household?
      !application.navigator.anyone_healthcare_enrolled?
    end
  end
end

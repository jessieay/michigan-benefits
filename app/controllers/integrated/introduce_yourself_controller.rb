module Integrated
  class IntroduceYourselfController < FormsController
    skip_before_action :ensure_application_present

    def update_models
      member_data = member_params.merge(relationship: "primary", requesting_food: "yes")

      if current_application
        current_application.primary_member.update(member_data)
        current_application.update(application_params)
      else
        application = CommonApplication.create(application_params)
        application.members.create(member_data)
        session[:current_application_id] = application.id
      end
    end

    private

    def existing_attributes
      if current_application
        attributes = current_application.attributes.
          merge(current_application.primary_member.attributes)
        HashWithIndifferentAccess.new(attributes)
      else
        {}
      end
    end
  end
end

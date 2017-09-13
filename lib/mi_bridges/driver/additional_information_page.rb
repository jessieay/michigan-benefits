module MiBridges
  class Driver
    class AdditionalInformationPage < ClickNextPage
      def fill_in_required_fields
        fill_in(
          "addUsrComments",
          with: snap_application.additional_information,
        )
      end
    end
  end
end
module MiBridges
  class Driver
    class JobIncomeInformationPage < FillInAndClickNextPage
      def self.title
        "Job Income Information"
      end

      delegate :primary_member, to: :snap_application
      delegate :employment_status, to: :primary_member

      def fill_in_required_fields
        check_fulltime_employment_status
        check_self_employment_status
        check_fap_program_benefits
      end

      private

      def check_fulltime_employment_status
        check_in_section(
          "starCurrentorRecentJob",
          condition: employment_status == "employed",
          for_label: primary_member.mi_bridges_formatted_name,
        )
      end

      def check_self_employment_status
        check_in_section(
          "starSelfEmployment",
          condition: employment_status == "self_employed",
          for_label: primary_member.mi_bridges_formatted_name,
        )
      end

      def check_fap_program_benefits
        check_no_one_in_section "starInKindIncome"
        check_no_one_in_section "starRefusaltoWork"
      end
    end
  end
end

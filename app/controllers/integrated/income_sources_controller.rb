module Integrated
  class IncomeSourcesController < MemberPerPageController
    def edit
      super

      # current_member.incomes.each do |income|
      #   @form.public_send("#{income.income_type}_income=", true)
      # end

      @form.incomes = Income::INCOME_LABELS_AND_KEYS.map do |income_type|
        Income.new(income_type: income_type)
      end
    end

    def update_models
      # (current_member.incomes.map(&:income_type) - member_params[:incomes])
      # (member_params[:incomes] - current_member.incomes.map(&:income_type))
      #
      Income::INCOME_LABELS_AND_KEYS.each do |key, _|
        if member_params["#{key}_income"] == "1"
          current_member.incomes.create(income_type: key)
        end
      end
    end

    private

    def set_default_values
      # current_member.baby_count ||= 1
    end
  end
end

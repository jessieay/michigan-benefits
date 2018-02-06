class IntroController < ApplicationController
  def edit
    app = SnapApplication.create
    session[:current_application_id] = app.id
    @form = IntroForm.new
  end

  def update
    current_application_id = session[:current_application_id]
    @form = IntroForm.new(member_params.merge(
      current_application_id: current_application_id,
    ))

    if @form.valid?
      flash[:success] = "Good job!!1"
      @form.save
      redirect_to intro_edit_path
    else
      render :edit
    end
  end

  private

  def member_params
    params.require(:intro_form).permit(:first_name, :last_name)
  end
end

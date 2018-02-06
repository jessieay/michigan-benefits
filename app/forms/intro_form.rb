class IntroForm
  include ActiveModel::Model

  attr_accessor(
    :current_application_id,
    :first_name,
    :last_name,
  )

  validates :first_name, presence: true
  validates :last_name, presence: true

  def save
    app = SnapApplication.find(current_application_id)
    app.members.create!({id => {first_name: "asdlf"}})
  end
end

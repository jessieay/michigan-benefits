require "rails_helper"

RSpec.feature "Integrated application" do
  include PdfHelper

  CIRCLED = Integrated::PdfAttributes::CIRCLED
  UNDERLINED = Integrated::PdfAttributes::UNDERLINED

  scenario "with multiple members", :js do
    visit before_you_start_sections_path

    on_page "Introduction" do
      expect(page).to have_content("Welcome")

      proceed_with "Continue"
    end

    on_page "Introduction" do
      expect(page).to have_content("To start, please introduce yourself")

      fill_in "What's your first name?", with: "Jessie"
      fill_in "What's your last name?", with: "Tester"

      select "January", from: "form_birthday_2i"
      select "1", from: "form_birthday_3i"
      select "1969", from: "form_birthday_1i"

      select_radio(question: "What's your sex?", answer: "Female")

      select_radio(
        question: "Have you received assistance in Michigan in the past (or currently)?",
        answer: "Yes",
      )

      proceed_with "Continue"
    end

    on_page "Introduction" do
      expect(page).to have_content("Do you currently reside in Michigan?")

      proceed_with "Yes"
    end

    on_page "Introduction" do
      expect(page).to have_content("What's your current living situation?")

      select_radio(
        question: "What's your current living situation?",
        answer: "Stable address",
      )

      proceed_with "Continue"
    end

    on_page "Introduction" do
      expect(page).to have_content("Every family is different")

      proceed_with "Continue"
    end

    on_page "Your Household" do
      expect(page).to have_content(
        "Who do you currently live with?",
      )
      expect(page).to have_content("Jessie Tester (that’s you!)")

      click_on "Add a member"
    end

    members = [
      {
        first_name: "Jonny",
        last_name: "Tester",
        dob: ["January", "1", "1969"],
        sex: "Female",
        relation: "Roommate",
      },
      {
        first_name: "Jackie",
        last_name: "Tester",
        dob: ["January", "1", "1970"],
        sex: "Male",
        relation: "Sibling",
      },
      {
        first_name: "Joe",
        last_name: "Schmoe",
        dob: ["Month", "Day", "Year"],
        sex: "Female",
        relation: "Parent",
      },
      {
        first_name: "Apples",
        last_name: "McMackintosh",
        dob: ["Month", "Day", "Year"],
        sex: "Male",
        relation: "Other",
      },
      {
        first_name: "Pupper",
        last_name: "McDog",
        dob: ["December", "30", "2016"],
        sex: "Male",
        relation: "Child",
      },
    ]

    members.each do |member|
      on_page "Your Household" do
        expect(page).to have_content("Add a person you want to apply with")

        fill_in "What's their first name?", with: member[:first_name]
        fill_in "What's their last name?", with: member[:last_name]

        select member[:dob][0], from: "form_birthday_2i"
        select member[:dob][1], from: "form_birthday_3i"
        select member[:dob][2], from: "form_birthday_1i"

        select_radio(question: "What's their sex?", answer: member[:sex])

        select member[:relation], from: "form_relationship"

        proceed_with "Continue"
      end

      on_page "Your Household" do
        expect(page).to have_content(
          "Who do you currently live with?",
        )

        expect(page).to have_content("#{member[:first_name]} #{member[:last_name]}")

        member == members.last ? click_on("Continue") : click_on("Add a member")
      end
    end

    on_page "Your Household" do
      expect(page).to have_content(
        "Who do you want to include on your Food Assistance application?",
      )

      check "Jonny Tester"
      check "Jackie Tester"
      check "Joe Schmoe"
      check "Pupper McDog"

      proceed_with "Continue"
    end

    on_page "Application Submitted" do
      expect(page).to have_content(
        "Congratulations",
      )
    end

    emails = ActionMailer::Base.deliveries

    raw_application_pdf = emails.last.attachments.first.body.raw_source
    temp_file = write_raw_pdf_to_temp_file(source: raw_application_pdf)
    pdf_values = filled_in_values(temp_file.path)

    expect(pdf_values["legal_name"]).to include("Jessie Tester")
    expect(pdf_values["is_homeless"]).to eq("No")
    expect(pdf_values["dob"]).to eq("01/01/1969")
    expect(pdf_values["received_assistance"]).to eq("Yes")
    expect(pdf_values["applying_for_food"]).to eq("Yes")
    expect(pdf_values["first_member_legal_name"]).to include("Jessie Tester")
    expect(pdf_values["first_member_female"]).to eq(CIRCLED)
    expect(pdf_values["first_member_dob"]).to eq("01/01/1969")
    expect(pdf_values["first_member_requesting_food"]).to eq(UNDERLINED)

    expect(pdf_values["second_member_relation"]).to eq("Roommate")
    expect(pdf_values["second_member_legal_name"]).to include("Jonny Tester")
    expect(pdf_values["second_member_female"]).to eq(CIRCLED)
    expect(pdf_values["second_member_dob"]).to eq("01/01/1969")
    expect(pdf_values["second_member_requesting_food"]).to eq(UNDERLINED)

    expect(pdf_values["third_member_relation"]).to eq("Sibling")
    expect(pdf_values["third_member_legal_name"]).to include("Jackie Tester")
    expect(pdf_values["third_member_male"]).to eq(CIRCLED)
    expect(pdf_values["third_member_dob"]).to eq("01/01/1970")
    expect(pdf_values["third_member_requesting_food"]).to eq(UNDERLINED)

    expect(pdf_values["fourth_member_relation"]).to eq("Parent")
    expect(pdf_values["fourth_member_legal_name"]).to include("Joe Schmoe")
    expect(pdf_values["fourth_member_female"]).to eq(CIRCLED)
    expect(pdf_values["fourth_member_dob"]).to eq("")
    expect(pdf_values["fourth_member_requesting_food"]).to eq(UNDERLINED)

    expect(pdf_values["fifth_member_relation"]).to eq("Other")
    expect(pdf_values["fifth_member_legal_name"]).to include("Apples McMackintosh")
    expect(pdf_values["fifth_member_male"]).to eq(CIRCLED)
    expect(pdf_values["fifth_member_dob"]).to eq("")
    expect(pdf_values["fifth_member_requesting_food"]).to eq("")

    expect(pdf_values["household_added_notes"]).to eq("Yes")
    expect(pdf_values["notes"]).to include("Additional Household Members:")
    expect(pdf_values["notes"]).to include(
      "Relation: Child, Legal name: Pupper McDog, Sex: Male, DOB: 12/30/2016, Applying for: Food",
    )
  end
end

require 'faker'
module UserHelpers

  def build_user
    FactoryBot.build(:user, email: Faker::Internet.email, password: Faker::Internet.password)
  end

  def create_user
    FactoryBot.create(:user, email: Faker::Internet.email, password: Faker::Internet.password)
  end

end

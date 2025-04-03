# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'faker'

5.times do
  family = Family.create!(name: "#{Faker::Name.last_name} Family")

  # Create a user for the family
  User.create!(
    email: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password",
    family: family
  )

  # Add 2 parents
  2.times do
    family.members.create!(
      name: Faker::Name.name,
      age: rand(30..45),
      is_parent: true,
      personality: Faker::Lorem.word,
      health: Faker::Lorem.sentence,
      development: Faker::Lorem.sentence,
      interests: Faker::Hobby.activity,
      needs: Faker::Lorem.words(number: 3).join(", ")
    )
  end

  # Add 3 children
  3.times do
    family.members.create!(
      name: Faker::Name.name,
      age: rand(4..18),
      is_parent: false,
      personality: Faker::Lorem.word,
      health: Faker::Lorem.sentence,
      development: Faker::Lorem.sentence,
      interests: Faker::Hobby.activity,
      needs: Faker::Lorem.words(number: 3).join(", ")
    )
  end
end
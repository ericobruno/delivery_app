namespace :user do
  desc "Create a test user"
  task create: :environment do
    email = "admin@example.com"
    password = "password123"
    name = "Admin User"
    
    user = User.find_or_initialize_by(email: email)
    user.password = password
    user.password_confirmation = password
    user.name = name
    
    if user.save
      puts "User created successfully!"
      puts "Email: #{user.email}"
      puts "Password: #{password}"
      puts "Name: #{user.name}"
    else
      puts "Error creating user:"
      puts user.errors.full_messages.join(", ")
    end
  end
end 
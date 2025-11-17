puts "🌱 Seeding database..."

# Create test users
puts "\n👥 Creating users..."
users = []

5.times do |i|
  user = User.find_or_create_by!(email: "player_#{i + 1}@example.com") do |u|
    u.username = "player_#{i + 1}"
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  users << user
  puts "  ✅ User: #{user.username}"
end

# Give some users initial stats
users[0].update!(wins: 10, losses: 3, draws: 2, points: 32)
users[1].update!(wins: 8, losses: 5, draws: 1, points: 25)
users[2].update!(wins: 5, losses: 5, draws: 0, points: 15)

puts "\n🏠 Creating rooms..."

# Create waiting rooms
room1 = Room.find_or_create_by!(name: "Room 1") do |r|
  r.master = users[0]
  r.status = :waiting
end
puts "  ✅ Room: #{room1.name}"

room2 = Room.find_or_create_by!(name: "Room 2") do |r|
  r.master = users[1]
  r.status = :waiting
end
puts "  ✅ Room: #{room2.name}"

puts "\n📊 Database seeded successfully!"
puts "\n🎮 Sample credentials:"
puts "  Username: player_1"
puts "  Password: password123"

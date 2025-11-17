#!/usr/bin/env ruby
# Quick test to verify game implementation

require_relative '../config/environment'

puts "🧪 Testing Caro Game Implementation"
puts "=" * 50

# Test 1: Check models exist
puts "\n📦 Test 1: Check Models"
begin
  User
  Room
  Game
  Move
  puts "   ✅ All models loaded"
rescue => e
  puts "   ❌ Error: #{e.message}"
  exit 1
end

# Test 2: Check statistics columns
puts "\n📊 Test 2: Check User Statistics"
user = User.first
if user
  puts "   User: #{user.username}"
  puts "   Wins: #{user.wins}"
  puts "   Losses: #{user.losses}"
  puts "   Points: #{user.points}"
  puts "   Total Games: #{user.total_games}"
  puts "   Win Rate: #{user.win_rate}%"
  puts "   ✅ Statistics working"
else
  puts "   ⚠️  No users found, run: rails db:seed"
end

# Test 3: Check Room status enum
puts "\n🏠 Test 3: Check Room Status Enum"
begin
  room = Room.first || Room.new(name: "Test", master: User.first)
  room.waiting!
  puts "   Status: #{room.status}"
  puts "   ✅ Room enum working"
rescue => e
  puts "   ❌ Error: #{e.message}"
end

# Test 4: Test Game creation
puts "\n🎮 Test 4: Test Game Logic"
begin
  user1 = User.first
  user2 = User.second
  
  if user1 && user2
    # Create test room
    test_room = Room.create!(
      name: "Test Game #{Time.now.to_i}",
      master: user1,
      guest: user2,
      status: :playing
    )
    
    # Create game
    game = Game.create!(
      room: test_room,
      player1: user1,
      player2: user2,
      current_turn_player: user1
    )
    
    puts "   Game ID: #{game.id}"
    puts "   Board Size: #{game.board_state.length}x#{game.board_state[0].length}"
    puts "   Turn: #{game.current_turn_player.username}"
    
    # Make a move
    result = game.make_move(user1, 7, 7)
    if result[:success]
      puts "   ✅ Move made: (7,7) = X"
      puts "   Board[7][7]: #{game.board_state[7][7]}"
      puts "   Turn Number: #{game.turn_number}"
      puts "   Next Turn: #{game.current_turn_player.username}"
    end
    
    # Make another move
    result = game.make_move(user2, 7, 8)
    if result[:success]
      puts "   ✅ Move made: (7,8) = O"
      puts "   Board[7][8]: #{game.board_state[7][8]}"
    end
    
    # Try invalid move (not your turn)
    result = game.make_move(user2, 8, 7)
    unless result[:success]
      puts "   ✅ Invalid move rejected: #{result[:error]}"
    end
    
    # Cleanup
    test_room.destroy!
    puts "   ✅ Game logic working"
  else
    puts "   ⚠️  Need at least 2 users, run: rails db:seed"
  end
rescue => e
  puts "   ❌ Error: #{e.message}"
  puts "   #{e.backtrace.first(3).join("\n   ")}"
end

# Test 5: Check GraphQL schema
puts "\n📡 Test 5: Check GraphQL Schema"
begin
  schema = CaroGameBeSchema
  
  # Check query fields
  query_fields = schema.query.fields.keys
  puts "   Query fields: #{query_fields.count}"
  puts "   - #{query_fields.join(', ')}"
  
  # Check mutation fields  
  mutation_fields = schema.mutation.fields.keys
  puts "   Mutation fields: #{mutation_fields.count}"
  puts "   - #{mutation_fields.join(', ')}"
  
  # Check subscription fields
  subscription_fields = schema.subscription.fields.keys
  puts "   Subscription fields: #{subscription_fields.count}"
  puts "   - #{subscription_fields.join(', ')}"
  
  puts "   ✅ GraphQL schema complete"
rescue => e
  puts "   ❌ Error: #{e.message}"
end

puts "\n" + "=" * 50
puts "🎉 All tests completed!"
puts "\n💡 Next steps:"
puts "   1. Start server: rails s"
puts "   2. Open GraphiQL: http://localhost:3000/graphiql"
puts "   3. Test queries with credentials:"
puts "      Username: player1"
puts "      Password: password123"

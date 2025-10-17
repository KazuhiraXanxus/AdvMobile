require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

// User data template - EDIT THIS to create different users
const userData = {
    firstName: "John",           // Change this
    lastName: "Doe",             // Change this
    age: "25",                   // Change this
    gender: "Male",              // Change this
    contactNumber: "09123456789", // Change this
    email: "john@example.com",   // Change this
    username: "johndoe",         // Change this
    password: "password123",     // Change this (will be hashed automatically)
    address: "123 Main St",      // Change this
    isActive: true,              // Keep as true
    type: "admin"                // Options: "admin", "editor", "viewer"
  };

async function createUser() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    // Check if user already exists
    const existingUser = await User.findOne({ email: userData.email });
    if (existingUser) {
      console.log(`❌ User with email ${userData.email} already exists!`);
      process.exit(1);
    }

    // Hash the password
    const hashedPassword = await bcrypt.hash(userData.password, 10);
    
    // Create the user
    const user = await User.create({
      ...userData,
      password: hashedPassword,
    });
    
    console.log('✅ User created successfully!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('User Details:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`ID: ${user._id}`);
    console.log(`Name: ${user.firstName} ${user.lastName}`);
    console.log(`Email: ${user.email}`);
    console.log(`Username: ${user.username}`);
    console.log(`Password: ${userData.password} (plain text)`);
    console.log(`Hashed: ${hashedPassword}`);
    console.log(`Type: ${user.type}`);
    console.log(`Age: ${user.age}`);
    console.log(`Gender: ${user.gender}`);
    console.log(`Contact: ${user.contactNumber}`);
    console.log(`Address: ${user.address}`);
    console.log(`Active: ${user.isActive}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createUser();


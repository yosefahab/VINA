// Read environment variables
const username = process.env.MONGO_USERNAME;
const password = process.env.MONGO_PASSWORD;
const database = process.env.MONGO_DB
//
// Connect to the admin database to create the user
const adminDb = db.getSiblingDB('admin');
// Create the initial admin user
adminDb.createUser({
    user: username,
    pwd: password,
    roles: [{ role: 'root', db: 'admin' }]
});

// Authenticate as the admin user
adminDb.auth(username, password);

// Switch to the "news" database
const db = db.getSiblingDB(database);

// Drop existing collections if they exist
db.articles.drop();
db.breaking_news.drop();


// Create collections with schema validation
import { readFileSync } from 'fs';
const schema = JSON.parse(readFileSync('schema.json', 'utf8'));
db.createCollection("articles", {
	validator: {
		$jsonSchema: schema
	}
});

db.createCollection("breaking_news", {
	validator: {
		$jsonSchema: schema
	}
});

// Create indexes to avoid duplication
db.articles.createIndex({ "url": 1 }, { unique: true });
db.breaking_news.createIndex({ "url": 1 }, { unique: true });

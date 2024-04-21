/// This script initializes the database from scratch using mongodb
// It creates a database "news" with two collections: (articles, breaking_news)
// The collections follow the schema specific in ./schema.json
// Note: This script should only be used once to initialize the database, otherwise it will erase all data!



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
	roles: [{ role: "root", db: "admin" }]
});

// Authenticate as the admin user
adminDb.auth(username, password);

// Switch to the "news" database
const db = db.getSiblingDB(database);
db.createUser({
	user: username,
	pwd: password,
	roles:[{ role: "dbOwner", db: "news"}]
});

// Drop existing collections if they exist
db.articles.drop();
db.breaking_news.drop();


// Create collections with schema validation
const schema = {
	"title": "articles",
	"bsonType": "object",
	"required": [
		"title",
		"date",
		"category",
		"url",
		"summary"
	],
	"properties": {
		"title": {
			"bsonType": "string"
		},
		"date": {
			"bsonType": "string"
		},
		"category": {
			"bsonType": "string"
		},
		"url": {
			"bsonType": "string"
		},
		"summary": {
			"bsonType": "string"
		}
	}
}
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

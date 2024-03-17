/// This script initializes the database from scratch using mongodb
// It creates a database "news" with two collections: (articles, breaking_news)
// The collections follow the schema specific in ./schema.json
// Note: This script should only be used once to initialize the database, otherwise it will erase all data!

const dotenv = require("dotenv");
const { MongoClient } = require("mongodb");

const schema = require("./schema.json");

async function main() {
	// read credentials from .env file
	dotenv.config({ path: "./.env"});

	const username = process.env.MONGO_USERNAME;
	const password = process.env.MONGO_PASSWORD;
	const port = process.env.MONGO_PORT;

	// connect to mongo
	const uri = `mongodb://${username}:${password}@localhost:${port}/news`
	const client = new MongoClient(uri);

	try {

		await client.connect();
		const db = client.db("news");

		// create collections from scratch, enforcing the schema
		await db.dropDatabase();

		await db.createUser({
			user: username,
			pwd: password,
			roles: [
				{
					role: "readWrite",
					db: "news"
				}
			]
		});

		await db.createCollection("articles", { validator: { $jsonSchema: schema } });
		await db.createCollection("breaking_news", { validator: { $jsonSchema: schema } });

		// create indexes to avoid duplicatation
		const articles = db.collection("articles");
		await articles.createIndex({ "url": 1 }, { unique: true });
		const breaking_news = db.collection("breaking_news");
		await breaking_news.createIndex({ "url": 1 }, { unique: true });

	} catch (error) {
		console.error(error);
	} finally {
		client.close();
	}
}

main();

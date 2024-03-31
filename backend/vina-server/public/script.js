let currentPage = 1;
let isLoading = false;
let lastId = null;

function createCard(title, text, url, date) { //HTMLLIElement
	function getDomainName(url) {
		const urlObject = new URL(url);
		return urlObject.hostname;
	}
	const card = document.createElement('li');

	const cardContent = document.createElement('div');
	cardContent.classList.add('card-content');

	const cardTitle = document.createElement('h2');
	cardTitle.classList.add('card-title');
	cardTitle.textContent = title;

	const cardSummary = document.createElement('p');
	cardSummary.textContent = text;

	const cardFooter = document.createElement('div');
	cardFooter.classList.add('card-footer');

	const cardUrlSpan = document.createElement('span');
	const cardUrlText = document.createTextNode("Source: ");
	const cardUrlLink = document.createElement('a');
	cardUrlLink.classList.add('card-url');
	cardUrlLink.href = url;
	cardUrlLink.textContent = getDomainName(url);
	cardUrlSpan.appendChild(cardUrlText);
	cardUrlSpan.appendChild(cardUrlLink);

	const cardDate = document.createElement('span');
	cardDate.classList.add('card-date');
	cardDate.textContent = "Date: " + date;

	cardFooter.appendChild(cardUrlSpan);
	cardFooter.appendChild(cardDate);

	cardContent.appendChild(cardTitle);
	cardContent.appendChild(cardSummary);

	card.appendChild(cardContent);
	card.appendChild(cardFooter);
	return card;
}
async function fetchArticles(newsList, loader) {
	if (isLoading) return;

	isLoading = true;
	loader.classList.add("show");

	// let requestUrl = `http://localhost:8080/articles/science?limit=5`
	const url = `http://localhost:8080/articles/science?limit=1${lastId ? `&offset=${lastId}` : ''}`;


	const response = await fetch(url)
		.catch(error => {
			console.error("Error fetching data:", error);
			return; // or handle the error in some other way
		});

	if (!response || response.status !== 200) {
		console.log("Bad response");
		return;
	}
	const articles = await response.json();

	if (articles.length === 0) {
		console.log("No More Data");
		return;
	}

	lastId = articles[articles.length - 1].id

	articles.forEach(article => {
		const card = createCard(article.title, article.summary, article.url, article.date);
		newsList.appendChild(card);
	});

	currentPage++;
	isLoading = false;
	loader.classList.remove("show");
}

document.addEventListener('DOMContentLoaded', () => {
	const loader = document.getElementById("loader");
	const newsList = document.getElementById('news-list');
	fetchArticles(newsList, loader);

	window.addEventListener('scroll', () => {
		if (window.innerHeight + window.scrollY >= document.body.offsetHeight) {
			fetchArticles(newsList, loader);
		}
	});
});

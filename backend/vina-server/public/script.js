let currentPage = 1;
let isLoading = false;

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

	const response = await fetch(`http://localhost:8080/articles/science?limit=5`);
	if (response.status.valueOf() !== 200) {
		console.log("Bad response");
		return;
	}
	const articles = await response.json();

	if (articles.length === 0) {
		console.log("Empty articles");
		return;
	}

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

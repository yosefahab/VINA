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
async function fetchArticles(newsList) {
	if (isLoading) return;

	isLoading = true;

	const response = await fetch(`http://localhost:8080/articles/science?limit=5`);
	const articles = await response.json();

	if (articles.length === 0) {
		console.log("Empty articles");
		return;
	}
	if (response.status.valueOf() !== 200) {
		console.log("Bad response");
		return;
	}

	articles.forEach(article => {
		const card = createCard(article.title, article.summary, article.url, article.date);
		newsList.appendChild(card);
	});

	currentPage++;
	isLoading = false;
}

document.addEventListener('DOMContentLoaded', () => {
	const newsList = document.getElementById('news-list');
	fetchArticles(newsList);

	window.addEventListener('scroll', () => {
		const { scrollTop, scrollHeight, clientHeight } = document.documentElement;
		if (scrollTop + clientHeight >= scrollHeight - 10) {
			fetchArticles(newsList);
		}
	});
});

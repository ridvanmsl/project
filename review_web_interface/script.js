/**
 * Business Review Analysis Web Interface
 * Handles review submission and display functionality
 */

const API_URL = 'https://5fac33336699.ngrok-free.app/api';

let selectedBusiness = 'amazon_business';
let selectedModel = 'amazon';

document.addEventListener('DOMContentLoaded', () => {
    setupEventListeners();
    loadRecentReviews();
});

function setupEventListeners() {
    // Business selector buttons
    const businessButtons = document.querySelectorAll('.business-btn');
    businessButtons.forEach(btn => {
        btn.addEventListener('click', (e) => {
            businessButtons.forEach(b => b.classList.remove('active'));
            e.currentTarget.classList.add('active');
            selectedBusiness = e.currentTarget.dataset.business;
            selectedModel = e.currentTarget.dataset.model;
            loadRecentReviews();
            hideResult();
        });
    });

    // Review form submission
    const form = document.getElementById('reviewForm');
    form.addEventListener('submit', handleSubmit);

    // Character counter
    const reviewText = document.getElementById('reviewText');
    reviewText.addEventListener('input', updateCharCount);

    // Refresh button
    const refreshBtn = document.getElementById('refreshBtn');
    refreshBtn.addEventListener('click', () => {
        loadRecentReviews();
    });
}

function updateCharCount() {
    const reviewText = document.getElementById('reviewText');
    const charCount = document.getElementById('charCount');
    charCount.textContent = reviewText.value.length;
}

async function handleSubmit(e) {
    e.preventDefault();

    const customerName = document.getElementById('customerName').value.trim();
    const rating = document.getElementById('rating').value;
    const reviewText = document.getElementById('reviewText').value.trim();

    if (!reviewText) {
        showError('Please enter a review text');
        return;
    }

    const submitBtn = document.getElementById('submitBtn');
    setLoading(true);

    try {
        const response = await fetch(`${API_URL}/reviews`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                business_id: selectedBusiness,
                text: reviewText,
                customer_name: customerName || null,
                rating: rating ? parseFloat(rating) : null,
                model_type: selectedModel
            })
        });

        const data = await response.json();

        if (response.ok) {
            showResult(data);
            document.getElementById('reviewForm').reset();
            updateCharCount();
            setTimeout(() => {
                loadRecentReviews();
            }, 1000);
        } else {
            showError(data.detail || 'Failed to process review');
        }
    } catch (error) {
        showError('Error connecting to server. Please make sure the backend is running.');
        console.error('Error:', error);
    } finally {
        setLoading(false);
    }
}

function setLoading(isLoading) {
    const submitBtn = document.getElementById('submitBtn');
    const btnText = submitBtn.querySelector('.btn-text');
    const btnLoading = submitBtn.querySelector('.btn-loading');
    
    submitBtn.disabled = isLoading;
    btnText.style.display = isLoading ? 'none' : 'inline';
    btnLoading.style.display = isLoading ? 'inline' : 'none';
}

function showResult(data) {
    const resultSection = document.getElementById('resultSection');
    const resultContent = document.getElementById('resultContent');

    resultContent.innerHTML = `
        <div class="result-success">
            <h3>✅ Review Submitted Successfully!</h3>
            <p><strong>Review ID:</strong> ${data.review_id}</p>
            <p><strong>Status:</strong> ${data.message}</p>
            <p style="margin-top: 15px;">
                ⚡ Your review is being analyzed by AI in the background.<br>
                📱 It will appear in the mobile app and recent reviews shortly.
            </p>
        </div>
    `;

    resultSection.style.display = 'block';
    resultSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function hideResult() {
    const resultSection = document.getElementById('resultSection');
    resultSection.style.display = 'none';
}

function showError(message) {
    alert('Error: ' + message);
}

async function loadRecentReviews() {
    const reviewsList = document.getElementById('reviewsList');
    reviewsList.innerHTML = '<div class="loading">Loading reviews...</div>';

    try {
        const response = await fetch(`${API_URL}/businesses/${selectedBusiness}/reviews`);
        
        if (!response.ok) {
            throw new Error('Failed to load reviews');
        }

        const reviews = await response.json();

        if (reviews.length === 0) {
            reviewsList.innerHTML = `
                <div class="no-reviews">
                    <p>No reviews yet for this business.</p>
                    <p>Be the first to submit one!</p>
                </div>
            `;
            return;
        }

        reviewsList.innerHTML = reviews.slice(0, 20).map(review => {
            const date = new Date(review.date).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
            const sentiment = review.overallSentiment || 'neutral';
            const sentimentClass = `sentiment-${sentiment}`;
            const sentimentEmoji = {
                'positive': '😊',
                'negative': '😞',
                'neutral': '😐'
            }[sentiment] || '📊';

            return `
                <div class="review-item">
                    <div class="review-header">
                        <span class="review-customer">${review.customerName || 'Anonymous'}</span>
                        <span class="review-date">${date}</span>
                    </div>
                    <div class="review-text">${escapeHtml(review.text)}</div>
                    <div class="review-sentiment">
                        <span class="sentiment-badge ${sentimentClass}">
                            ${sentimentEmoji} ${sentiment.toUpperCase()}
                        </span>
                        ${review.rating ? `<span>⭐ ${review.rating}/5</span>` : ''}
                    </div>
                    ${review.aspects && review.aspects.length > 0 ? `
                        <div class="aspect-list">
                            ${review.aspects.slice(0, 5).map(aspect => `
                                <span class="sentiment-badge sentiment-${aspect.sentiment}">
                                    ${aspect.category.replace(/_/g, ' ')}
                                </span>
                            `).join('')}
                        </div>
                    ` : ''}
                </div>
            `;
        }).join('');
    } catch (error) {
        reviewsList.innerHTML = `
            <div class="no-reviews">
                <p>Error loading reviews.</p>
                <p>${error.message}</p>
                <p>Make sure the backend server is running at ${API_URL}</p>
            </div>
        `;
        console.error('Error loading reviews:', error);
    }
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}


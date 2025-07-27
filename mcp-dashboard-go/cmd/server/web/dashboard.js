// WebSocket connection
let ws = null;
let reconnectInterval = null;

// Chart instances
let toolUsageChart = null;
let activityTimelineChart = null;
let principleChart = null;
let branchChart = null;
let cognitiveLoadChart = null;

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    initCharts();
    connectWebSocket();
    fetchMetrics();
    
    // Fetch metrics every 5 seconds
    setInterval(fetchMetrics, 5000);
});

function connectWebSocket() {
    const wsUrl = `ws://${window.location.host}/ws`;
    ws = new WebSocket(wsUrl);
    
    ws.onopen = () => {
        console.log('WebSocket connected');
        updateConnectionStatus(true);
        clearInterval(reconnectInterval);
    };
    
    ws.onmessage = (event) => {
        const data = JSON.parse(event.data);
        handleRealtimeUpdate(data);
    };
    
    ws.onclose = () => {
        console.log('WebSocket disconnected');
        updateConnectionStatus(false);
        // Reconnect after 3 seconds
        reconnectInterval = setInterval(() => {
            connectWebSocket();
        }, 3000);
    };
    
    ws.onerror = (error) => {
        console.error('WebSocket error:', error);
    };
}

function updateConnectionStatus(connected) {
    const status = document.getElementById('connection-status');
    if (connected) {
        status.textContent = 'Connected';
        status.className = 'tag is-success';
    } else {
        status.textContent = 'Disconnected';
        status.className = 'tag is-danger';
    }
}

function handleRealtimeUpdate(data) {
    // Add to live feed
    addToLiveFeed(data);
    
    // Update charts if needed
    fetchMetrics();
}

function addToLiveFeed(entry) {
    const feed = document.getElementById('live-feed');
    const item = document.createElement('div');
    item.className = 'feed-item';
    
    const time = new Date(entry.timestamp).toLocaleTimeString();
    const status = entry.status === 'SUCCESS' ? 
        '<span class="tag is-success is-small">SUCCESS</span>' : 
        '<span class="tag is-danger is-small">ERROR</span>';
    
    item.innerHTML = `
        <span class="has-text-grey">${time}</span>
        [${entry.server || 'unknown'}] 
        <strong>${entry.tool || 'unknown'}</strong>
        ${status}
        <span class="has-text-grey-light">${entry.details || ''}</span>
    `;
    
    // Insert at top of feed
    if (feed.firstChild.classList && feed.firstChild.classList.contains('has-text-grey')) {
        feed.innerHTML = '';
    }
    feed.insertBefore(item, feed.firstChild);
    
    // Keep only last 20 entries
    while (feed.children.length > 20) {
        feed.removeChild(feed.lastChild);
    }
}

async function fetchMetrics() {
    try {
        const response = await fetch('/api/metrics');
        const data = await response.json();
        updateDashboard(data);
    } catch (error) {
        console.error('Error fetching metrics:', error);
    }
}

function updateDashboard(data) {
    // Update summary cards
    document.getElementById('total-calls').textContent = data.summary.totalToolCalls || 0;
    document.getElementById('success-rate').textContent = 
        `${((data.summary.overallSuccessRate || 0) * 100).toFixed(1)}%`;
    document.getElementById('avg-exec-time').textContent = 
        `${(data.summary.averageExecutionTime || 0).toFixed(0)}ms`;
    document.getElementById('error-rate').textContent = 
        `${((data.summary.errorRate || 0) * 100).toFixed(1)}%`;
    
    // Update charts
    updateToolUsageChart(data.toolCalls);
    updateActivityTimeline(data.activityTimeline);
    updatePrincipleChart(data.principleUsage);
    updateBranchChart(data.branchActivity);
    updateCognitiveLoadChart(data.cognitiveLoad);
}

function initCharts() {
    // Tool Usage Chart
    const toolUsageCtx = document.getElementById('tool-usage-chart').getContext('2d');
    toolUsageChart = new Chart(toolUsageCtx, {
        type: 'bar',
        data: {
            labels: [],
            datasets: [{
                label: 'Tool Calls',
                data: [],
                backgroundColor: 'rgba(54, 162, 235, 0.6)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    
    // Activity Timeline Chart
    const activityCtx = document.getElementById('activity-timeline-chart').getContext('2d');
    activityTimelineChart = new Chart(activityCtx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Tool Calls',
                data: [],
                borderColor: 'rgba(75, 192, 192, 1)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                tension: 0.1
            }, {
                label: 'Errors',
                data: [],
                borderColor: 'rgba(255, 99, 132, 1)',
                backgroundColor: 'rgba(255, 99, 132, 0.2)',
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true
                }
            }
        }
    });
    
    // Principle Chart
    const principleCtx = document.getElementById('principle-chart').getContext('2d');
    principleChart = new Chart(principleCtx, {
        type: 'doughnut',
        data: {
            labels: [],
            datasets: [{
                data: [],
                backgroundColor: [
                    'rgba(255, 99, 132, 0.6)',
                    'rgba(54, 162, 235, 0.6)',
                    'rgba(255, 206, 86, 0.6)',
                    'rgba(75, 192, 192, 0.6)',
                    'rgba(153, 102, 255, 0.6)'
                ]
            }]
        },
        options: {
            responsive: true
        }
    });
    
    // Branch Chart
    const branchCtx = document.getElementById('branch-chart').getContext('2d');
    branchChart = new Chart(branchCtx, {
        type: 'pie',
        data: {
            labels: [],
            datasets: [{
                data: [],
                backgroundColor: [
                    'rgba(255, 159, 64, 0.6)',
                    'rgba(255, 99, 132, 0.6)',
                    'rgba(54, 162, 235, 0.6)',
                    'rgba(255, 206, 86, 0.6)',
                    'rgba(75, 192, 192, 0.6)'
                ]
            }]
        },
        options: {
            responsive: true
        }
    });
    
    // Cognitive Load Chart
    const cognitiveCtx = document.getElementById('cognitive-load-chart').getContext('2d');
    cognitiveLoadChart = new Chart(cognitiveCtx, {
        type: 'radar',
        data: {
            labels: ['Low', 'Medium', 'High'],
            datasets: [{
                label: 'Distribution',
                data: [0, 0, 0],
                borderColor: 'rgba(255, 99, 132, 1)',
                backgroundColor: 'rgba(255, 99, 132, 0.2)'
            }]
        },
        options: {
            responsive: true,
            scales: {
                r: {
                    beginAtZero: true
                }
            }
        }
    });
}

function updateToolUsageChart(toolCalls) {
    if (!toolCalls) return;
    
    const labels = Object.keys(toolCalls).slice(0, 10); // Top 10
    const data = labels.map(label => toolCalls[label]);
    
    toolUsageChart.data.labels = labels;
    toolUsageChart.data.datasets[0].data = data;
    toolUsageChart.update();
}

function updateActivityTimeline(timeline) {
    if (!timeline || timeline.length === 0) return;
    
    const labels = timeline.slice(-20).map(point => 
        new Date(point.time).toLocaleTimeString()
    );
    const toolCalls = timeline.slice(-20).map(point => point.toolCalls);
    const errors = timeline.slice(-20).map(point => point.errors);
    
    activityTimelineChart.data.labels = labels;
    activityTimelineChart.data.datasets[0].data = toolCalls;
    activityTimelineChart.data.datasets[1].data = errors;
    activityTimelineChart.update();
}

function updatePrincipleChart(principles) {
    if (!principles) return;
    
    const labels = Object.keys(principles);
    const data = labels.map(label => principles[label]);
    
    principleChart.data.labels = labels;
    principleChart.data.datasets[0].data = data;
    principleChart.update();
}

function updateBranchChart(branches) {
    if (!branches) return;
    
    const labels = Object.keys(branches).slice(0, 5); // Top 5
    const data = labels.map(label => branches[label]);
    
    branchChart.data.labels = labels;
    branchChart.data.datasets[0].data = data;
    branchChart.update();
}

function updateCognitiveLoadChart(cognitiveLoad) {
    if (!cognitiveLoad) return;
    
    const data = [
        cognitiveLoad.low || 0,
        cognitiveLoad.medium || 0,
        cognitiveLoad.high || 0
    ];
    
    cognitiveLoadChart.data.datasets[0].data = data;
    cognitiveLoadChart.update();
}
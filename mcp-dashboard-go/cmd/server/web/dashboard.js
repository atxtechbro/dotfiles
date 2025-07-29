// WebSocket connection
let ws = null;
let reconnectInterval = null;

// Chart instances
let toolUsageChart = null;
let activityTimelineChart = null;
let branchChart = null;

// Dashboard state
let isPaused = false;
let currentToolView = 'bar';

// Dark mode support
const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)');
const currentTheme = localStorage.getItem('theme') || (prefersDarkScheme.matches ? 'dark' : 'light');

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    // Apply theme
    if (currentTheme === 'dark') {
        document.body.classList.add('dark-mode');
        updateThemeIcon('dark');
    }
    
    // Theme toggle listener
    document.getElementById('theme-toggle').addEventListener('click', toggleTheme);
    
    initCharts();
    connectWebSocket();
    fetchMetrics();
    
    // Fetch metrics every 5 seconds
    setInterval(fetchMetrics, 5000);
    
    // Add smooth loading animation
    setTimeout(() => {
        document.querySelectorAll('.card').forEach((card, index) => {
            card.style.animation = `slideIn 0.5s ease-out ${index * 0.1}s forwards`;
        });
    }, 100);
});

// Theme management
function toggleTheme() {
    const isDark = document.body.classList.toggle('dark-mode');
    const theme = isDark ? 'dark' : 'light';
    localStorage.setItem('theme', theme);
    updateThemeIcon(theme);
    
    // Update charts theme
    updateChartsTheme();
}

function updateThemeIcon(theme) {
    const icon = document.querySelector('#theme-toggle i');
    icon.className = theme === 'dark' ? 'fas fa-sun' : 'fas fa-moon';
}

function updateChartsTheme() {
    const isDark = document.body.classList.contains('dark-mode');
    const textColor = isDark ? '#f9fafb' : '#111827';
    const gridColor = isDark ? '#374151' : '#e5e7eb';
    
    // Update all charts
    [toolUsageChart, activityTimelineChart, branchChart].forEach(chart => {
        if (chart) {
            chart.options.plugins.legend.labels.color = textColor;
            chart.options.scales.x && (chart.options.scales.x.ticks.color = textColor);
            chart.options.scales.y && (chart.options.scales.y.ticks.color = textColor);
            chart.options.scales.x && (chart.options.scales.x.grid.color = gridColor);
            chart.options.scales.y && (chart.options.scales.y.grid.color = gridColor);
            chart.update();
        }
    });
}

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
    if (isPaused) return;
    
    // Add to live feed
    addToLiveFeed(data);
    
    // Update charts if needed
    fetchMetrics();
}

function addToLiveFeed(entry) {
    const feed = document.getElementById('live-feed');
    
    // Remove placeholder if exists
    const placeholder = feed.querySelector('.has-text-centered');
    if (placeholder) {
        placeholder.remove();
    }
    
    const item = document.createElement('div');
    item.className = 'feed-item';
    item.style.opacity = '0';
    
    const time = new Date(entry.timestamp).toLocaleTimeString();
    const status = entry.status === 'SUCCESS' ? 
        '<span class="tag is-success is-small">SUCCESS</span>' : 
        '<span class="tag is-danger is-small">ERROR</span>';
    
    const serverIcon = getServerIcon(entry.server);
    const duration = entry.duration ? `<span class="has-text-info ml-2">${entry.duration}ms</span>` : '';
    
    item.innerHTML = `
        <div class="is-flex is-align-items-center is-justify-content-space-between">
            <div>
                <span class="has-text-grey">${time}</span>
                <i class="${serverIcon} mx-2"></i>
                <strong>${entry.tool || 'unknown'}</strong>
                ${status}
                ${duration}
            </div>
            <button class="delete is-small" onclick="this.parentElement.parentElement.remove()"></button>
        </div>
        ${entry.details ? `<div class="has-text-grey-light mt-1">${entry.details}</div>` : ''}
    `;
    
    // Insert at top of feed
    feed.insertBefore(item, feed.firstChild);
    
    // Animate in
    setTimeout(() => {
        item.style.opacity = '1';
    }, 10);
    
    // Keep only last 20 entries
    while (feed.children.length > 20) {
        feed.removeChild(feed.lastChild);
    }
}

function getServerIcon(server) {
    const icons = {
        'git': 'fab fa-git-alt',
        'github': 'fab fa-github',
        'brave': 'fas fa-search',
        'playwright': 'fas fa-robot'
    };
    return icons[server] || 'fas fa-server';
}

// Dashboard controls
function clearFeed() {
    const feed = document.getElementById('live-feed');
    feed.innerHTML = `
        <div class="has-text-centered has-text-grey p-5">
            <i class="fas fa-satellite-dish fa-3x mb-3"></i>
            <p>Feed cleared. Waiting for new tool calls...</p>
        </div>
    `;
}

function pauseFeed() {
    isPaused = !isPaused;
    const button = event.target.closest('button');
    const icon = button.querySelector('i');
    const text = button.querySelector('span:last-child');
    
    if (isPaused) {
        icon.className = 'fas fa-play';
        text.textContent = 'Resume';
        button.classList.add('is-warning');
    } else {
        icon.className = 'fas fa-pause';
        text.textContent = 'Pause';
        button.classList.remove('is-warning');
    }
}

function changeToolView(type) {
    currentToolView = type;
    
    // Update button states
    document.querySelectorAll('.field.has-addons button').forEach(btn => {
        btn.classList.remove('is-primary');
    });
    event.target.closest('button').classList.add('is-primary');
    
    // Recreate chart with new type
    const ctx = document.getElementById('tool-usage-chart').getContext('2d');
    const data = toolUsageChart.data;
    const options = toolUsageChart.options;
    
    toolUsageChart.destroy();
    
    toolUsageChart = new Chart(ctx, {
        type: type,
        data: data,
        options: {
            ...options,
            indexAxis: type === 'bar' ? 'y' : undefined,
            plugins: {
                ...options.plugins,
                legend: {
                    ...options.plugins.legend,
                    display: type === 'doughnut'
                }
            }
        }
    });
    
    updateChartsTheme();
}

function refreshBranchData() {
    const button = event.target.closest('button');
    button.classList.add('is-loading');
    
    fetchMetrics().then(() => {
        setTimeout(() => {
            button.classList.remove('is-loading');
        }, 500);
    });
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
    updateBranchChart(data.branchActivity);
}

function initCharts() {
    const isDark = document.body.classList.contains('dark-mode');
    const textColor = isDark ? '#f9fafb' : '#111827';
    const gridColor = isDark ? '#374151' : '#e5e7eb';
    
    // Chart defaults
    Chart.defaults.font.family = '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
    Chart.defaults.font.size = 12;
    Chart.defaults.color = textColor;
    
    // Tool Usage Chart
    const toolUsageCtx = document.getElementById('tool-usage-chart').getContext('2d');
    toolUsageChart = new Chart(toolUsageCtx, {
        type: currentToolView,
        data: {
            labels: [],
            datasets: [{
                label: 'Tool Calls',
                data: [],
                backgroundColor: [
                    'rgba(99, 102, 241, 0.8)',
                    'rgba(139, 92, 246, 0.8)',
                    'rgba(167, 139, 250, 0.8)',
                    'rgba(129, 140, 248, 0.8)',
                    'rgba(79, 70, 229, 0.8)'
                ],
                borderColor: [
                    'rgba(99, 102, 241, 1)',
                    'rgba(139, 92, 246, 1)',
                    'rgba(167, 139, 250, 1)',
                    'rgba(129, 140, 248, 1)',
                    'rgba(79, 70, 229, 1)'
                ],
                borderWidth: 2,
                borderRadius: 8,
                hoverBorderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            indexAxis: currentToolView === 'bar' ? 'y' : undefined,
            plugins: {
                legend: {
                    display: currentToolView === 'doughnut',
                    position: 'right',
                    labels: {
                        color: textColor,
                        padding: 15,
                        font: {
                            size: 12
                        }
                    }
                },
                tooltip: {
                    backgroundColor: isDark ? '#1f2937' : '#ffffff',
                    titleColor: textColor,
                    bodyColor: textColor,
                    borderColor: gridColor,
                    borderWidth: 1,
                    padding: 12,
                    cornerRadius: 8,
                    displayColors: false
                }
            },
            scales: currentToolView === 'bar' ? {
                x: {
                    beginAtZero: true,
                    grid: {
                        color: gridColor,
                        drawBorder: false
                    },
                    ticks: {
                        color: textColor
                    }
                },
                y: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        color: textColor
                    }
                }
            } : {}
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
                borderColor: '#10b981',
                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                tension: 0.4,
                borderWidth: 3,
                pointRadius: 0,
                pointHoverRadius: 6,
                pointHoverBackgroundColor: '#10b981',
                pointHoverBorderColor: '#ffffff',
                pointHoverBorderWidth: 2
            }, {
                label: 'Errors',
                data: [],
                borderColor: '#ef4444',
                backgroundColor: 'rgba(239, 68, 68, 0.1)',
                tension: 0.4,
                borderWidth: 3,
                pointRadius: 0,
                pointHoverRadius: 6,
                pointHoverBackgroundColor: '#ef4444',
                pointHoverBorderColor: '#ffffff',
                pointHoverBorderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
                mode: 'index',
                intersect: false
            },
            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                    labels: {
                        color: textColor,
                        padding: 15,
                        usePointStyle: true,
                        pointStyle: 'circle'
                    }
                },
                tooltip: {
                    backgroundColor: isDark ? '#1f2937' : '#ffffff',
                    titleColor: textColor,
                    bodyColor: textColor,
                    borderColor: gridColor,
                    borderWidth: 1,
                    padding: 12,
                    cornerRadius: 8
                }
            },
            scales: {
                x: {
                    grid: {
                        color: gridColor,
                        drawBorder: false
                    },
                    ticks: {
                        color: textColor,
                        maxRotation: 0,
                        maxTicksLimit: 8
                    }
                },
                y: {
                    beginAtZero: true,
                    grid: {
                        color: gridColor,
                        drawBorder: false
                    },
                    ticks: {
                        color: textColor
                    }
                }
            }
        }
    });
    
    // Branch Chart
    const branchCtx = document.getElementById('branch-chart').getContext('2d');
    branchChart = new Chart(branchCtx, {
        type: 'doughnut',
        data: {
            labels: [],
            datasets: [{
                data: [],
                backgroundColor: [
                    'rgba(99, 102, 241, 0.8)',
                    'rgba(139, 92, 246, 0.8)',
                    'rgba(167, 139, 250, 0.8)',
                    'rgba(16, 185, 129, 0.8)',
                    'rgba(245, 158, 11, 0.8)'
                ],
                borderColor: isDark ? '#1f2937' : '#ffffff',
                borderWidth: 2,
                hoverBorderWidth: 3,
                hoverOffset: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            cutout: '60%',
            plugins: {
                legend: {
                    display: true,
                    position: 'bottom',
                    labels: {
                        color: textColor,
                        padding: 15,
                        font: {
                            size: 12
                        }
                    }
                },
                tooltip: {
                    backgroundColor: isDark ? '#1f2937' : '#ffffff',
                    titleColor: textColor,
                    bodyColor: textColor,
                    borderColor: gridColor,
                    borderWidth: 1,
                    padding: 12,
                    cornerRadius: 8
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

function updateBranchChart(branches) {
    if (!branches) return;
    
    const labels = Object.keys(branches).slice(0, 5); // Top 5
    const data = labels.map(label => branches[label]);
    
    branchChart.data.labels = labels;
    branchChart.data.datasets[0].data = data;
    branchChart.update();
}
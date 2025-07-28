package watcher

import (
	"sync"
	"time"
)

// Metrics holds calculated metrics from log entries
type Metrics struct {
	mu sync.RWMutex

	// Tool usage counts
	ToolCalls map[string]int `json:"toolCalls"`
	
	// Success/error rates by tool
	SuccessRates map[string]float64 `json:"successRates"`
	
	// Execution times by tool (average in ms)
	ExecutionTimes map[string]float64 `json:"executionTimes"`
	
	// Activity over time (5-minute buckets)
	ActivityTimeline []TimelinePoint `json:"activityTimeline"`
	
	// Principle usage
	PrincipleUsage map[string]int `json:"principleUsage"`
	
	// Error counts by server
	ErrorCounts map[string]int `json:"errorCounts"`
	
	// Branch activity
	BranchActivity map[string]int `json:"branchActivity"`
	
	// Cognitive load distribution
	CognitiveLoad map[string]int `json:"cognitiveLoad"`
}

// TimelinePoint represents activity at a point in time
type TimelinePoint struct {
	Time       time.Time `json:"time"`
	ToolCalls  int       `json:"toolCalls"`
	Errors     int       `json:"errors"`
	AvgExecTime float64  `json:"avgExecTime"`
}

// NewMetrics creates a new metrics instance
func NewMetrics() *Metrics {
	return &Metrics{
		ToolCalls:      make(map[string]int),
		SuccessRates:   make(map[string]float64),
		ExecutionTimes: make(map[string]float64),
		PrincipleUsage: make(map[string]int),
		ErrorCounts:    make(map[string]int),
		BranchActivity: make(map[string]int),
		CognitiveLoad:  make(map[string]int),
		ActivityTimeline: make([]TimelinePoint, 0),
	}
}

// UpdateFromEntry updates metrics based on a log entry
func (m *Metrics) UpdateFromEntry(entry LogEntry) {
	m.mu.Lock()
	defer m.mu.Unlock()

	// Update tool calls
	if entry.Tool != "" {
		m.ToolCalls[entry.Tool]++
	}

	// Update success rates
	if entry.Status == "SUCCESS" || entry.Status == "ERROR" {
		toolKey := entry.Server + ":" + entry.Tool
		if entry.Status == "SUCCESS" {
			// Simple success rate calculation (would need more sophisticated tracking)
			current := m.SuccessRates[toolKey]
			m.SuccessRates[toolKey] = (current + 1.0) / 2.0
		} else {
			current := m.SuccessRates[toolKey]
			m.SuccessRates[toolKey] = current / 2.0
		}
	}

	// Update error counts
	if entry.Status == "ERROR" {
		m.ErrorCounts[entry.Server]++
	}

	// Update branch activity
	if entry.Branch != "" && entry.Branch != "unknown" {
		m.BranchActivity[entry.Branch]++
	}

	// Update from metadata
	if entry.Type == "meta" && entry.Parameters != nil {
		// Update execution times
		if execTime, ok := entry.Parameters["execution_ms"].(float64); ok {
			current := m.ExecutionTimes[entry.Tool]
			// Simple moving average
			m.ExecutionTimes[entry.Tool] = (current + execTime) / 2.0
		}

		// Update principle usage
		if principle, ok := entry.Parameters["principle"].(string); ok {
			m.PrincipleUsage[principle]++
		}

		// Update cognitive load
		if opContext, ok := entry.Parameters["operation_context"].(map[string]interface{}); ok {
			if load, ok := opContext["cognitive_load"].(string); ok {
				m.CognitiveLoad[load]++
			}
		}
	}

	// Update timeline (simplified - would bucket by time in production)
	m.updateTimeline(entry)
}

func (m *Metrics) updateTimeline(entry LogEntry) {
	// Find or create timeline point for current 5-minute bucket
	bucket := entry.Timestamp.Truncate(5 * time.Minute)
	
	var point *TimelinePoint
	for i := range m.ActivityTimeline {
		if m.ActivityTimeline[i].Time.Equal(bucket) {
			point = &m.ActivityTimeline[i]
			break
		}
	}
	
	if point == nil {
		m.ActivityTimeline = append(m.ActivityTimeline, TimelinePoint{
			Time: bucket,
		})
		point = &m.ActivityTimeline[len(m.ActivityTimeline)-1]
	}
	
	// Update point
	if entry.Type == "tool_call" {
		point.ToolCalls++
	}
	if entry.Status == "ERROR" {
		point.Errors++
	}
	if execTime, ok := entry.Parameters["execution_ms"].(float64); ok {
		// Simple average
		point.AvgExecTime = (point.AvgExecTime + execTime) / 2.0
	}
}

// GetSnapshot returns a copy of current metrics
func (m *Metrics) GetSnapshot() Metrics {
	m.mu.RLock()
	defer m.mu.RUnlock()
	
	// Deep copy the metrics
	snapshot := Metrics{
		ToolCalls:      make(map[string]int),
		SuccessRates:   make(map[string]float64),
		ExecutionTimes: make(map[string]float64),
		PrincipleUsage: make(map[string]int),
		ErrorCounts:    make(map[string]int),
		BranchActivity: make(map[string]int),
		CognitiveLoad:  make(map[string]int),
		ActivityTimeline: make([]TimelinePoint, len(m.ActivityTimeline)),
	}
	
	// Copy maps
	for k, v := range m.ToolCalls {
		snapshot.ToolCalls[k] = v
	}
	for k, v := range m.SuccessRates {
		snapshot.SuccessRates[k] = v
	}
	for k, v := range m.ExecutionTimes {
		snapshot.ExecutionTimes[k] = v
	}
	for k, v := range m.PrincipleUsage {
		snapshot.PrincipleUsage[k] = v
	}
	for k, v := range m.ErrorCounts {
		snapshot.ErrorCounts[k] = v
	}
	for k, v := range m.BranchActivity {
		snapshot.BranchActivity[k] = v
	}
	for k, v := range m.CognitiveLoad {
		snapshot.CognitiveLoad[k] = v
	}
	
	// Copy timeline
	copy(snapshot.ActivityTimeline, m.ActivityTimeline)
	
	return snapshot
}
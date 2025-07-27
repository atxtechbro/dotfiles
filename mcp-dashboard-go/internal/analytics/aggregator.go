package analytics

import (
	"encoding/json"
	"net/http"

	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/watcher"
)

// Aggregator collects and aggregates metrics from log entries
type Aggregator struct {
	metrics *watcher.Metrics
}

// NewAggregator creates a new analytics aggregator
func NewAggregator() *Aggregator {
	return &Aggregator{
		metrics: watcher.NewMetrics(),
	}
}

// AddEntry processes a new log entry
func (a *Aggregator) AddEntry(entry watcher.LogEntry) {
	a.metrics.UpdateFromEntry(entry)
}

// ServeHTTP handles HTTP requests for metrics
func (a *Aggregator) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	snapshot := a.metrics.GetSnapshot()
	
	// Add computed metrics
	response := struct {
		watcher.Metrics
		Summary Summary `json:"summary"`
	}{
		Metrics: snapshot,
		Summary: a.computeSummary(snapshot),
	}
	
	json.NewEncoder(w).Encode(response)
}

// Summary contains high-level computed metrics
type Summary struct {
	TotalToolCalls       int     `json:"totalToolCalls"`
	OverallSuccessRate   float64 `json:"overallSuccessRate"`
	MostUsedTool         string  `json:"mostUsedTool"`
	MostActiveBranch     string  `json:"mostActiveBranch"`
	DominantPrinciple    string  `json:"dominantPrinciple"`
	AverageExecutionTime float64 `json:"averageExecutionTime"`
	ErrorRate            float64 `json:"errorRate"`
	RecentActivity       string  `json:"recentActivity"` // "high", "medium", "low"
}

func (a *Aggregator) computeSummary(m watcher.Metrics) Summary {
	s := Summary{}
	
	// Total tool calls
	for _, count := range m.ToolCalls {
		s.TotalToolCalls += count
	}
	
	// Most used tool
	maxCount := 0
	for tool, count := range m.ToolCalls {
		if count > maxCount {
			maxCount = count
			s.MostUsedTool = tool
		}
	}
	
	// Overall success rate
	totalSuccess := 0.0
	count := 0.0
	for _, rate := range m.SuccessRates {
		totalSuccess += rate
		count++
	}
	if count > 0 {
		s.OverallSuccessRate = totalSuccess / count
	}
	
	// Most active branch
	maxBranch := 0
	for branch, count := range m.BranchActivity {
		if count > maxBranch {
			maxBranch = count
			s.MostActiveBranch = branch
		}
	}
	
	// Dominant principle
	maxPrinciple := 0
	for principle, count := range m.PrincipleUsage {
		if count > maxPrinciple {
			maxPrinciple = count
			s.DominantPrinciple = principle
		}
	}
	
	// Average execution time
	totalTime := 0.0
	timeCount := 0.0
	for _, time := range m.ExecutionTimes {
		totalTime += time
		timeCount++
	}
	if timeCount > 0 {
		s.AverageExecutionTime = totalTime / timeCount
	}
	
	// Error rate
	totalErrors := 0
	for _, count := range m.ErrorCounts {
		totalErrors += count
	}
	if s.TotalToolCalls > 0 {
		s.ErrorRate = float64(totalErrors) / float64(s.TotalToolCalls)
	}
	
	// Recent activity level
	if len(m.ActivityTimeline) > 0 {
		recent := m.ActivityTimeline[len(m.ActivityTimeline)-1]
		if recent.ToolCalls > 50 {
			s.RecentActivity = "high"
		} else if recent.ToolCalls > 10 {
			s.RecentActivity = "medium"
		} else {
			s.RecentActivity = "low"
		}
	}
	
	return s
}
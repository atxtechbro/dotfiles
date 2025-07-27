package watcher

import (
	"bufio"
	"encoding/json"
	"io"
	"log"
	"os"
	"strings"
	"time"

	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/analytics"
	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/websocket"
	"github.com/fsnotify/fsnotify"
)

// LogEntry represents a parsed log entry
type LogEntry struct {
	Timestamp  time.Time              `json:"timestamp"`
	Server     string                 `json:"server"`
	Tool       string                 `json:"tool"`
	Status     string                 `json:"status"`
	Branch     string                 `json:"branch"`
	Details    string                 `json:"details"`
	Parameters map[string]interface{} `json:"parameters,omitempty"`
	Type       string                 `json:"type"` // "tool_call", "error", or "meta"
}

// WatchFile watches a log file for changes and broadcasts updates
func WatchFile(path string, hub *websocket.Hub, aggregator *analytics.Aggregator) {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Printf("Error creating watcher for %s: %v", path, err)
		return
	}
	defer watcher.Close()

	// Open file and seek to end
	file, err := os.Open(path)
	if err != nil {
		log.Printf("Error opening %s: %v", path, err)
		return
	}
	defer file.Close()

	// Seek to end of file
	file.Seek(0, io.SeekEnd)

	// Add file to watcher
	err = watcher.Add(path)
	if err != nil {
		log.Printf("Error watching %s: %v", path, err)
		return
	}

	log.Printf("Watching file: %s", path)

	for {
		select {
		case event, ok := <-watcher.Events:
			if !ok {
				return
			}
			if event.Op&fsnotify.Write == fsnotify.Write {
				entries := readNewLines(file, path)
				for _, entry := range entries {
					// Update aggregator
					aggregator.AddEntry(entry)

					// Broadcast to WebSocket clients
					data, err := json.Marshal(entry)
					if err == nil {
						hub.Broadcast <- data
					}
				}
			}

		case err, ok := <-watcher.Errors:
			if !ok {
				return
			}
			log.Printf("Watcher error for %s: %v", path, err)
		}
	}
}

func readNewLines(file *os.File, path string) []LogEntry {
	var entries []LogEntry
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		line := scanner.Text()
		entry := parseLogLine(line, path)
		if entry != nil {
			entries = append(entries, *entry)
		}
	}

	return entries
}

func parseLogLine(line, path string) *LogEntry {
	entry := &LogEntry{
		Parameters: make(map[string]interface{}),
	}

	// Determine log type based on file name
	if strings.Contains(path, "mcp-tool-calls.log") {
		entry.Type = "tool_call"
		parseToolCallLog(line, entry)
	} else if strings.Contains(path, "mcp-errors.log") {
		entry.Type = "error"
		parseErrorLog(line, entry)
	} else if strings.Contains(path, "mcp-meta-analytics.jsonl") {
		entry.Type = "meta"
		parseMetaLog(line, entry)
	}

	return entry
}

func parseToolCallLog(line string, entry *LogEntry) {
	// Parse format: "timestamp: [SERVER] TOOL_CALL: tool | STATUS: status | BRANCH: branch | DETAILS: details"
	parts := strings.Split(line, " | ")
	if len(parts) < 4 {
		return
	}

	// Parse timestamp and server
	timePart := strings.Split(parts[0], ": ")
	if len(timePart) >= 2 {
		entry.Timestamp, _ = time.Parse("2006-01-02 15:04:05", timePart[0])
		serverPart := strings.TrimPrefix(timePart[1], "[")
		serverPart = strings.TrimSuffix(serverPart, "] TOOL_CALL")
		entry.Server = serverPart
	}

	// Parse tool name
	if len(timePart) >= 3 {
		entry.Tool = strings.TrimSpace(timePart[2])
	}

	// Parse other fields
	for _, part := range parts[1:] {
		kv := strings.SplitN(part, ": ", 2)
		if len(kv) == 2 {
			switch kv[0] {
			case "STATUS":
				entry.Status = kv[1]
			case "BRANCH":
				entry.Branch = kv[1]
			case "DETAILS":
				entry.Details = kv[1]
			case "PARAMS":
				// Try to parse JSON params
				json.Unmarshal([]byte(kv[1]), &entry.Parameters)
			}
		}
	}
}

func parseErrorLog(line string, entry *LogEntry) {
	// Similar parsing logic for error logs
	parts := strings.Split(line, ": ")
	if len(parts) >= 3 {
		entry.Timestamp, _ = time.Parse("2006-01-02 15:04:05", parts[0])
		serverPart := strings.TrimPrefix(parts[1], "[")
		serverPart = strings.TrimSuffix(serverPart, "] MCP ERROR")
		entry.Server = serverPart
		entry.Status = "ERROR"
		entry.Details = strings.Join(parts[2:], ": ")
	}
}

func parseMetaLog(line string, entry *LogEntry) {
	// Parse JSONL format
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(line), &data); err == nil {
		if ts, ok := data["timestamp"].(float64); ok {
			entry.Timestamp = time.Unix(int64(ts), 0)
		}
		if tool, ok := data["tool"].(string); ok {
			entry.Tool = tool
		}
		if metadata, ok := data["metadata"].(map[string]interface{}); ok {
			entry.Parameters = metadata
		}
	}
}
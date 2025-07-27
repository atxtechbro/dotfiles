package main

import (
	"embed"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/analytics"
	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/watcher"
	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/websocket"
	"github.com/gorilla/websocket"
)

//go:embed all:web/*
var webContent embed.FS

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow connections from any origin
	},
}

func main() {
	// Create WebSocket hub
	hub := websocket.NewHub()
	go hub.Run()

	// Initialize analytics aggregator
	aggregator := analytics.NewAggregator()

	// Start file watchers
	logPaths := []string{
		filepath.Join(os.Getenv("HOME"), "mcp-tool-calls.log"),
		filepath.Join(os.Getenv("HOME"), "mcp-errors.log"),
		filepath.Join(os.Getenv("HOME"), "mcp-meta-analytics.jsonl"),
	}

	for _, path := range logPaths {
		go watcher.WatchFile(path, hub, aggregator)
	}

	// Set up HTTP routes
	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		serveWS(hub, w, r)
	})

	// Serve static files
	http.Handle("/", http.FileServer(http.FS(webContent)))

	// API endpoints
	http.HandleFunc("/api/metrics", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		aggregator.ServeHTTP(w, r)
	})

	port := os.Getenv("MCP_DASHBOARD_PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("MCP Dashboard starting on http://localhost:%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

func serveWS(hub *websocket.Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	client := &websocket.Client{
		Hub:  hub,
		Conn: conn,
		Send: make(chan []byte, 256),
	}
	client.Hub.Register <- client

	go client.WritePump()
	go client.ReadPump()
}
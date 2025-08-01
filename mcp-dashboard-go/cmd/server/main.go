package main

import (
	"embed"
	"io/fs"
	"log"
	"net/http"
	"os"
	"path/filepath"

	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/analytics"
	"github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/watcher"
	ws "github.com/atxtechbro/dotfiles/mcp-dashboard-go/internal/websocket"
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
	hub := ws.NewHub()
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

	// Serve static files from embedded web directory
	webFS, err := fs.Sub(webContent, "web")
	if err != nil {
		log.Fatal("Failed to create sub filesystem: ", err)
	}
	http.Handle("/", http.FileServer(http.FS(webFS)))

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

func serveWS(hub *ws.Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	client := &ws.Client{
		Hub:  hub,
		Conn: conn,
		Send: make(chan []byte, 256),
	}
	client.Hub.Register <- client

	go client.WritePump()
	go client.ReadPump()
}
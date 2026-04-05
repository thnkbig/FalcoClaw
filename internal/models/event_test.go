package models

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEventJSONRoundTrip(t *testing.T) {
	event := Event{
		UUID:     "evt-test-001",
		Output:   "Test event output",
		Priority: "CRITICAL",
		Rule:     "shell_injection",
		Time:     time.Now().UTC(),
		OutputFields: map[string]interface{}{
			"proc.name": "python3",
			"proc.pid":  float64(12345),
		},
		Source:   "syscall",
		Tags:     []string{"shell", "injection"},
		Hostname: "test-host",
	}
	data, err := json.Marshal(event)
	require.NoError(t, err)
	var decoded Event
	err = json.Unmarshal(data, &decoded)
	require.NoError(t, err)
	assert.Equal(t, event.UUID, decoded.UUID)
	assert.Equal(t, event.Rule, decoded.Rule)
}

func TestGetStringField(t *testing.T) {
	event := Event{
		OutputFields: map[string]interface{}{
			"proc.name": "bash",
			"user.name": "root",
			"proc.pid":  float64(9999),
		},
	}
	assert.Equal(t, "bash", event.GetProcessName())
	assert.Equal(t, "root", event.GetUserName())
	assert.Equal(t, "9999", event.GetPID())
	assert.Equal(t, "", event.GetSourceIP())
}

func TestGetSourceIP(t *testing.T) {
	event := Event{OutputFields: map[string]interface{}{"fd.sip": "192.168.1.100"}}
	assert.Equal(t, "192.168.1.100", event.GetSourceIP())
}

func TestGetFileName(t *testing.T) {
	event := Event{OutputFields: map[string]interface{}{"fd.name": "/etc/shadow"}}
	assert.Equal(t, "/etc/shadow", event.GetFileName())
}

func TestMissingField(t *testing.T) {
	event := Event{OutputFields: map[string]interface{}{}}
	assert.Equal(t, "", event.GetProcessName())
	assert.Equal(t, "", event.GetPID())
}
